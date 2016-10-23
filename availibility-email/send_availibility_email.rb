require 'nokogiri'
require 'mechanize'
require 'action_view'

include ActionView::Helpers::SanitizeHelper

def get_html(user, pwd)
	agent = Mechanize.new
	agent.get('https://mdcc.secure-club.com/admin/v2/login.aspx') do |login_page|
		test = login_page.form_with(:id => 'form1') do |form|
		    username_field = form.field_with(:id => 'txtLogin')
			username_field.value = user
			password_field = form.field_with(:id => 'txtPassword')
			password_field.value = pwd

			button = form.button_with(:id => 'btnSubmit')
			home_page = form.submit(button)
		end
	end

	agent.get('https://mdcc.secure-club.com/admin/v2/availabilitiesPrint.aspx?teamid=0&gender=&start=23%20Oct%202016&end=23%20Nov%202016') do |availibilities_page|
		return availibilities_page.content
	end
end

def strip_tag(str)
	strip_tags(str.to_s).strip
end

def parse_html(html)
	page = Nokogiri::HTML(html)
	table = page.css(".rgMasterTable")

	table.search('tr').each do |tr|
		td = tr.search('td').map.to_a 
		unless td[1].to_s.include? "Fixture Date:" 
			if (td[5].to_s.include? "Available") || (td[5].to_s.include? "Unsure")
				puts strip_tag(td[1]) + " => " + strip_tag(td[2]) + " => " + strip_tag(td[5]) + " => " + strip_tag(td[6]) 
			end
		end
	end
end

def send_email(user, pwd)
	availibilities_html = parse_html(get_html(user, pwd))
end

