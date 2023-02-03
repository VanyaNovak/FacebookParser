require 'selenium-webdriver'
require 'capybara/dsl'
require 'csv'
require 'pry'

class FacebookParser
  include Capybara::DSL

  FACEBOOK_URI = "https://www.facebook.com/"
  DEFAULT_CONTACTS_COUNT = 20

  def initialize(email, password)
    @email = email
    @password = password
    @session = Capybara::Session.new(:selenium)
  end

  def contacts_list
    return "authorization failed" unless auth

    export_data(collect_names)
  end

  private

  def collect_names
    names = []

    (1..DEFAULT_CONTACTS_COUNT).each do |i|
      names << find_element(:xpath, "/html/body/div[1]/div/div[1]/div/div[3]/div/div/div/div[1]/div[1]/div/div[3]/div/div/div[1]/div/div[2]/div/div[2]/div/ul/li[#{ i }]/div/div/a/div[1]/div[2]/div/div/div/div/span").text
    end

    names
  end

  def export_data(data)
    CSV.open("data.csv", "w") do |csv|
      data.each do |el|
        csv << [el]
      end
    end
  end

  def auth
    visit(FACEBOOK_URI)

    find_element(:xpath, "//*[@id='email']").set(@email)
    find_element(:xpath, "//*[@id='pass']").set(@password)
    find_element(:xpath, "/html/body/div[1]/div[1]/div[1]/div/div/div/div[2]/div/div[1]/form/div[2]/button").click

    true unless has_element?("/html/body/div[1]/div[1]/div[1]/div/div[2]/div[2]/form/div/div[2]/div[2]") || has_element?("/html/body/div[3]/div[2]/div/div/div/div/div[2]")
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
