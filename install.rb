# Update apt-get
#apt-get update
include_recipe 'apt'

# Build Ruby
#apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3
package "ruby" do
  version 2.1.3
end

# Ruby may install to /usr/local/bin
#
# So you may need to make copies of the core commands into /usr/bin
# cp /usr/local/bin/ruby /usr/bin/ruby
# cp /usr/local/bin/gem /usr/bin/gem

bash "copy_files" do
  code <<-EOL
  cp /usr/local/bin/ruby /usr/bin/ruby
  cp /usr/local/bin/gem /usr/bin/gemunzip
  EOL
end

# Install apache
#apt-get install apache2
package ["apache2", "git"]

# Configure apache

a2enmod proxy_http
a2enmod rewrite
cp blog.conf /etc/apache2/sites-enabled/blog.conf
rm /etc/apache2/sites-enabled/000-default.conf

# Restart apache
#service apache2 restart
service ['apache2', 'thin'] do
  action [:enable, :start]
end

# Install Git
#apt-get install git

# Clone the repo

git clone https://github.com/learnchef/middleman-blog.git

cd middleman-blog

# Install Bundler
#gem install bundler
gem_package 'bundler'

# Install project dependencies
#bundle install
#> should not be run as root. So another should be created
user 'bundle_user' do
  manage_home true
  comment 'Bundle User'
  home '/home/bundle_user'
  shell '/bin/bash'
  password '$6$6IZeIf0i$V8bXDbwWQSciwFTGG.fmiZOgyu/kdTwahsAw6XwK.7Yn4clhIK39Vm3PyMzHlOnBbfqgaG.7FVJ69C09T9ujK1'
end
execute 'bundle install' do
  cwd '/myapp'
  user 'bundle_user'
  not_if 'bundle check'
end


# Install thin service
thin install
/usr/sbin/update-rc.d -f thin defaults

# Create a new thin config for the blog and copy into /etc/thin
# SEE THE UPDATED /etc/thin/blog.conf BELOW

# Fix the /etc/init.d/thin script to incude HOME variable
# SEE THE UPDATED /etc/init.d/thin script BELOW

# Start / Re-start the thin service

service thin restart
# Restart apache
#service apache2 restart
service ['apache2', 'thin'] do
  action [:enable, :start]
end

