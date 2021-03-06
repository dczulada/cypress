class CalculatedProductTestControllerTest < ActionController::TestCase
  tests ProductTestsController

  setup do
    collection_fixtures('vendors', '_id',"user_ids")
    collection_fixtures('query_cache', 'test_id')
    collection_fixtures('measures', "_id", "bundle_id")
    collection_fixtures('bundles', "_id")
    collection_fixtures('products','_id','vendor_id')
    collection_fixtures('users',"_id", "vendor_ids")
    collection_fixtures('records', '_id')
    collection_fixtures('product_tests', '_id')

    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.where({:first_name => 'bobby', :last_name => 'tables'}).first
    sign_in @user
  end

  test "create without patients" do
     product = Product.where({}).first
     pt = {:product_id=>product.id,:name =>'new4', :effective_date =>'12/21/2011', _type: "CalculatedProductTest",:measure_ids => ["0013","0028","0421","" ]}

     get :create, {:bundle_id=>Bundle.first.id,:product_test => pt , :type=>"CalculatedProductTest" }
     assert_response :redirect, "Should redirect to show page"
     assert_equal 1, CalculatedProductTest.where({:name => 'new4'}).count, "should have created a calculated product test"
  end




end
