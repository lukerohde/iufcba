Given(/^there's an agreement titled "(.*?)" expiring "(.*?)"$/) do |title, expiry|
	@agreement = FactoryGirl.create(:agreement, name: title, end_date: Date.parse(expiry))
end

When(/^I am on the homepage$/) do
	visit root_path
end

Then(/^I should see the "(.*?)" agreement$/) do |title|
	@agreement = Rec.find_by_name(title)
	page.should have_content(@agreement.name)
	page.should have_content(@agreement.end_date)
end

Then(/^I should see the link "(.*?)"$/) do |link_name|
	page.should have_link(link_name)
end

When(/^I click the "(.*?)" link$/) do |link_name|
	click_link(link_name)
end

Then(/^I see a list of "(.*?)"$/) do |items|
	page.should have_content("Listing #{items}")
end
