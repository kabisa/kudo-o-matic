# frozen_string_literal: true

namespace :diagrams do
  desc 'Generates a class diagram and saves it to the docs folder'
  task :generate do
    `bin/erd` # Use .erdconfig for configuration
  end
end
