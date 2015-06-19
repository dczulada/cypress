require "health-data-standards"
module Validators
  class ExpectedResultsValidator < QrdaFileValidator
    include HealthDataStandards::Validate::ReportedResultExtractor
    attr_accessor :reported_results

    def initialize(file, expected_results)
      @document = get_document(file)
      @expected_results = expected_results
      @reported_results = {}
    end

    # Nothing to see here - Move along
    def validate()
      validation_errors = []
      @expected_results.each_pair do |key,expected_result|
        result_key = expected_result["population_ids"].dup

        reported_result, errors = extract_results_by_ids(expected_result['measure_id'], result_key)
        @reported_results[key] = reported_result
        validation_errors.concat match_calculation_results(expected_result,reported_result)
      end
      validation_errors
    end

    private

    def match_calculation_results(expected_result, reported_result)
      validation_errors = []
      measure_id = expected_result["measure_id"]
      logger = -> (message, stratification) {
        validation_errors << ExecutionError.new(message: message, msg_type: :error, measure_id: measure_id,
                  validator_type: :result_validation, stratification: stratification)
      }

      check_for_reported_results_population_ids(expected_result, reported_result, logger)
      return validation_errors if validation_errors.present?

      _ids = expected_result["population_ids"].dup
      # remove the stratification entry if its there, not needed to test against values
      stratification = _ids.delete("stratification")
      logger_with_stratification = -> (message) {logger.call(message, stratification)}
      _ids.keys.each do |pop_key|
        if expected_result[pop_key].present?
          check_population(expected_result, reported_result, pop_key, stratification, logger)
          # Check supplemental data elements
          ex_sup = (expected_result["supplemental_data"] || {})[pop_key]
          reported_sup  = (reported_result[:supplemental_data] || {})[pop_key]
          if stratification.nil? && ex_sup

            sup_keys = ex_sup.keys.reject(&:blank?)
            # check to see if we expect sup data and if they provide it a short circuit the rest of the testing
            # if they do not
            if sup_keys.length>0 && reported_sup.nil?
              err = "supplemental data for #{pop_key} not found expected  #{ex_sup}"
              logger_with_stratification.call(err)
            else
              # for each supplemental data item (RACE, ETHNICITY,PAYER,SEX)
              sup_keys.each do |sup_key|
                sup_value  = (ex_sup[sup_key] || {}).reject{|k,v| (k.blank? || v.blank? || v=="UNK")}
                reported_sup_value = reported_sup[sup_key]
                check_supplemental_data(sup_value, reported_sup_value, pop_key, sup_key, logger_with_stratification)
              end
            end
          end
        end
      end
      validation_errors
    end

    def check_for_reported_results_population_ids(expected_result, reported_result, logger)
      _ids = expected_result["population_ids"].dup
      if reported_result.nil? || reported_result.keys.length <= 1
        message = "Could not find entry for measure #{expected_result["measure_id"]} with the following population ids "
        message +=  _ids.inspect
        logger.call(message, _ids['stratification'])
      end
    end

    def check_population(expected_result, reported_result, pop_key, stratification, logger)
      # only add the error that they dont match if there was an actual result
      if !reported_result.empty? && !reported_result.has_key?(pop_key)
        message = "Could not find value"
        message += " for stratification #{stratification} " if stratification
        message += " for Population #{pop_key}"
        logger.call(message, stratification)
      elsif (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?
        err = "expected #{pop_key} #{expected_result["population_ids"][pop_key]} value #{expected_result[pop_key]} does not match reported value #{reported_result[pop_key]}"
        logger.call(err, stratification)
      end
    end

    def check_supplemental_data(expected_supplemental_value, reported_supplemantal_value, population_key, supplemental_data_key, logger)
      if reported_supplemantal_value.nil?
        err = "supplemental data for #{population_key} #{supplemental_data_key} #{expected_supplemental_value} expected but was not found"
        logger.call(err)
      else
        expected_supplemental_value.each_pair do |code,value|
          if code != "UNK" && value != reported_supplemantal_value[code]
            err = "expected supplemental data for #{population_key} #{supplemental_data_key} #{code} value [#{value}] does not match reported supplemental data value [#{ reported_supplemantal_value[code]}]"
            logger.call(err)
          end
        end
        reported_supplemantal_value.each_pair do |code,value|
          if value > 0
            if expected_supplemental_value[code].nil?
              err = "unexpected supplemental data for #{population_key} #{supplemental_data_key} #{code}"
              logger.call(err)
            end
          end
        end
      end
    end

  end
end
