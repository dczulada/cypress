require 'test_helper'
require 'zip/zip'

class ProductTestTest < ActiveSupport::TestCase
  setup do

    collection_fixtures('test_executions', '_id', "product_test_id")
    collection_fixtures('measures', '_id', "bundle_id")
    collection_fixtures('bundles', '_id')
    collection_fixtures('product_tests', '_id','bundle_id')

    @test1 = ProductTest.find("4f58f8de1d41c851eb000478")
    @test2 = ProductTest.find("4f5a606b1d41c851eb000484")
  end

  test "Should know if it's passing" do
    assert_equal true,  @test1.passing?
    assert_equal false, @test2.passing?
  end


  test "should know its execution state" do
    assert_equal :passed,  @test1.execution_state
    assert_equal :failed , @test2.execution_state
  end


  test "Should return the measure defs" do
    defs = @test1.measures

    assert defs[0].key == "0001"
    assert defs[1].key == "0002"
  end

  test "should be able to retrieve patient records to evaluate against" do

  end

  test "Should know how many measures it's testing" do
    assert_equal 2, @test1.measures.count
  end


end
