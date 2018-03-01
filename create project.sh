#!/bin/bash
# Requirements
# git, yarn, mysql in path, wp-cli and wp-cli-dotenv-command
# install wp-cli with: composer global require wp-cli/wp-cli
# instal dotenv with: wp package install aaemnnosttv/wp-cli-dotenv-command:^1.0

htdocs="d:/MAMP/htdocs/" #set path to your project root. Could be a symlink or something like that as well?
username="username" # set username, could be a read input as well
password="password" # set admin password, could be a read input as well in the future.
email="someone@something.com" # set admin email
tld="local" # you could use dev, local, test or antything of your liking without the first dot.

echo "Setting up some variables for the install"

read -p 'Project name (without extention):' projectname
read -p 'Project type (new/existing):' projecttype

echo "Setting up a $projecttype project in $projectname.$tld"
cd
# moves to htdocs folder
cd $htdocs

# created dir based on project name
mkdir $projectname.$tld
cd $projectname.$tld
if [ "$projecttype" == "new" ]; then

  # cloning bedrock and removing unneeded dirs
  echo "Cloning bedrock"
  git clone https://github.com/roots/bedrock.git .
  rm -rf .git
  rm -rf .github

  # cloning baseplate, could add extra flavors in future
  echo "Cloning BasePlate"
  git clone https://github.com/Levdbas/BasePlate.git $htdocs/$projectname.$tld/web/app/themes/$projectname
  rm -rf $htdocs/$projectname.$tld/web/app/themes/$projectname/.git
  mv $htdocs/$projectname.$tld/web/app/themes/$projectname/assets  $htdocs/$projectname.$tld/
  mv $htdocs/$projectname.$tld/web/app/themes/$projectname/app/*  $htdocs/$projectname.$tld/web/app/themes/$projectname/
  mv $htdocs/$projectname.$tld/web/app/themes/$projectname/package.json  $htdocs/$projectname.$tld/
  rm -rf $htdocs/$projectname.$tld/web/app/themes/$projectname/app/
fi

# install dependencies
if command --version yarn &>/dev/null; then
    echo "Yarn isn't installed, falling back to npm install"
    npm install &
else
    echo "Yarn is installed."
    yarn install &
fi

composer install &

# wait for the above three tasks to finish up.
wait

# create repo
git init

# adding node modules to .gitignore
echo 'node_modules/*' >> .gitignore

# create database
mysql -uroot -proot -e "CREATE DATABASE $projectname"

# creating .env file, could be created with the dotenv package as well. To do in the future.
echo "Creating .env file"
cat > .env << EOF
DB_NAME=$projectname
DB_USER=root
DB_PASSWORD=root
# Optional variables
# DB_HOST=$tldhost
# DB_PREFIX=wp_

WP_ENV=development
WP_HOME=http://$projectname.$tld
WP_SITEURL=http://$projectname.$tld/wp

# Generate your keys here: https://roots.io/salts.html
AUTH_KEY='generateme'
SECURE_AUTH_KEY='generateme'
LOGGED_IN_KEY='generateme'
NONCE_KEY='generateme'
AUTH_SALT='generateme'
SECURE_AUTH_SALT='generateme'
LOGGED_IN_SALT='generateme'
NONCE_SALT='generateme'
EOF
read -p "Add site to AMP stack before pressing ENTER to continue"



if which wp > /dev/null
then
    echo "WP CLI installed, running WP install"
    # install WordPress with vars from start of this file.
    wp core install --url="http://$projectname.$tld" --title="$projectname" --admin_user="$username" --admin_password="$password" --admin_email="$email"

    # block search engines
    wp option set blog_public 0

    # generate salts for the .env file
    wp dotenv salts generate
else
    echo "WP CLI not installed, skipping WP install"
fi
read -p "All done, press enter to close..."
