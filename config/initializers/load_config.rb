res = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")[RAILS_ENV]
if res
  APP_CONFIG = res.symbolize_keys
end