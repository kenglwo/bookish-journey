import sys
import os
from selenium import webdriver

driver = webdriver.Chrome("chromedriver.exe")
driver.get("https://beef.center.kobe-u.ac.jp/")

username = driver.find_element_by_css_selector("input#j_username")
username.send_keys('YOUR_ID')

password = driver.find_element_by_css_selector("input#j_password")
password.send_keys('YOUR_PASSWORD')

submit = driver.find_element_by_css_selector("input[type='submit']")
submit.click()

