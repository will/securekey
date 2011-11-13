require './app/secure_key'
desc 'rotate all'
task :rotate do
  User.all.each do |u|
    begin
      puts "rotating #{u.id}: #{u.heroku_id}"
      u.rotate_keys!
    rescue
      next
    end
  end
end


