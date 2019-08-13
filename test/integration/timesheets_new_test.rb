require 'test_helper'

class TimesheetsNewTest < ActionDispatch::IntegrationTest
  # Ensure that if invalid data is entered, no timesheet is created.
	test "invalid timesheet information" do
		get new_path
		assert_no_difference 'Timesheet.count' do
			post timesheets_path, params: { timesheet: {
				date: Date.tomorrow,
				start: Time.now + 1800,
				finish: Time.now - 1800}   }
		end
		 # Ensure the app re-renders the 'new' page with error messages displayed.
		assert_template 'timesheets/new'
		assert_select 'div#error_explanation'
  	assert_select 'div.field_with_errors'
	end

	# Check that a timesheet is successfully created when valid data is entered.
	test "valid timesheet information" do
		get new_path
		assert_difference 'Timesheet.count', 1 do
			post timesheets_path, params: { timesheet:{
				date: Date.new(2000,1,1),
				start: Time.httpdate("Sat, 01 Jan 2000 03:00:00 GMT"),
				finish: Time.httpdate("Sat, 01 Jan 2000 13:30:00 GMT")}	}
		end
		# Check that the app redirects to index and correctly calculates pay.
		follow_redirect!
		assert_template 'timesheets/index'
		assert Timesheet.last.pay == 493.50
	end

	test "overlapping timesheet entries" do
		Timesheet.create(date: Date.new(2000,1,1), 
			start: Time.httpdate("Sat, 01 Jan 2000 09:00:00 GMT"), 
			finish: Time.httpdate("Sat, 01 Jan 2000 17:00:00 GMT"))
		get new_path
		# Check that if an overlapping timesheet entry is submitted, it does not save.
		assert_no_difference 'Timesheet.count' do
			post timesheets_path, params: { timesheet: {
				date: Date.new(2000,1,1),
				start: Time.httpdate("Sat, 01 Jan 2000 07:23:00 GMT"),
				finish: Time.httpdate("Sat, 01 Jan 2000 10:47:00 GMT")}   }
		end
		# Ensure 'new' page is re-rendered and error message is displayed.
		assert_template 'timesheets/new'
		assert_select 'div#error_explanation'
	end

end
