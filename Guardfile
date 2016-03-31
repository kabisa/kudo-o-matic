guard 'minitest' do

  # with Minitest::Unit
  watch(%r|^test/(.*)\/?test_(.*)\.rb|)
  watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r|^test/test_helper\.rb|)    { "test" }

  # Rails 4 - App Files
  watch(%r|^app/controllers/(.*)\.rb|) { |m| "test/controllers/#{m[1]}_test.rb" }
  watch(%r|^app/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*)\.rb|)      { |m| "test/models/#{m[1]}_test.rb" }  
  watch(%r|^app/decorators/(.*)\.rb|)  { |m| "test/decorators/#{m[1]}_test.rb" }  

  # Rails 4 - Test Files
  watch(%r|^test/controllers/(.*)\.rb|) { |m| "test/controllers/#{m[1]}.rb" }
  watch(%r|^test/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}.rb" }
  watch(%r|^test/features/(.*)\.rb|)    { |m| "test/features/#{m[1]}.rb" }  
  watch(%r|^test/mailers/(.*)\.rb|)     { |m| "test/mailers/#{m[1]}.rb" }  
  watch(%r|^test/models/(.*)\.rb|)      { |m| "test/models/#{m[1]}.rb" }  
  watch(%r|^test/decorators/(.*)\.rb|)  { |m| "test/decorators/#{m[1]}.rb" }  

end
