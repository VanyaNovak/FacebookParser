require 'selenium-webdriver'
require 'capybara/dsl'
require 'capybara'
require 'csv'
require 'pry'

class FacebookParser
  include Capybara::DSL

  attr_reader :authorized, :session

  FACEBOOK_URI = "https://www.facebook.com/"
  DEFAULT_CONTACTS_COUNT = 20
  CSV_FILE = "data.csv"
  TRANSLATIONS = %w[Contacts Контакты]

  def initialize(email, password)
    @email = email
    @password = password
    @session = Capybara::Session.new(:selenium)

    @authorized = auth
  end

  def contacts_list
    return export_data(collect_names) if @authorized && !collect_names.nil?
  end

  private

  def collect_names
    TRANSLATIONS.each do |translation|
      if has_element?("//span[contains(text(), '#{translation}')]")
        names = @session.find_all(:xpath, "//div[contains(.//span, '#{translation}')]").map(&:text)
        return names.join("\n").split("\n").select { |i| i.match(/([\p{Letter}]+\s?\b){2,}/) }.uniq
      end
    end

    nil
  end

  def export_data(data)
    CSV.open(CSV_FILE, "w") do |csv|
      data.each do |el|
        csv << [el]
      end
    end
  end

  def auth
    visit(FACEBOOK_URI)

    find_element(:xpath, "//input[@id='email']").set(@email)
    find_element(:xpath, "//input[@id='pass']").set(@password)
    find_element(:xpath, "//button[contains(@name, 'login')]").click

    return false if has_element?("//div[contains(@id, 'error_box')]") || has_element?("//div[contains(@aria-labelledby, 'Assistive Identification')]")

    true
  end

  def visit(uri)
    @session.visit(uri)
  end

  def find_element(*args)
    @session.find(*args)
  end

  def has_element?(xpath)
    @session.has_xpath?(xpath)
  end
end
