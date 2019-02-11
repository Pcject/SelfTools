from unittest import loader

start_path = ''
pattern = '*.py'

suites = loader.TestLoader().discover(start_path, pattern)
suites.run()