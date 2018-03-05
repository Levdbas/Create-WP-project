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
DBuser="root" #mysql database user
DBpassword="root" #mysql database user password

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
if yarn install; then
  yarn install &
  echo "Yarn is installed."
else
  echo "Yarn isn't installed, falling back to npm install"
  npm install &
fi

composer install &

# wait for the above three tasks to finish up.
wait

# create repo
git init

# adding node modules to .gitignore
echo 'node_modules/*' >> .gitignore

# create database
mysql -u$DBuser -p$DBpassword -e "CREATE DATABASE $projectname"

# set browsersync URL in config file.
sed -i '2s/.*/" browserSyncURL": "'$projectname.$tld'",/' $htdocs/$projectname.$tld/assets/config.json

read -p "Script will try to install WP with WP-cli, $(tput setaf 3)$(tput smul)add site to your AMP stack before pressing enter to continue. $(tput sgr 0)"
if which wp > /dev/null
then
echo "WP CLI installed, continuing install"
echo "Creating .env file"
wp dotenv init --template=.env.example --with-salts
wp dotenv set DB_NAME $projectname
wp dotenv set DB_USER $DBuser
wp dotenv set DB_PASSWORD $DBpassword
wp dotenv set WP_HOME http://$projectname.$tld
wp dotenv set WP_SITEURL http://$projectname.$tld/wp

echo "Installing WordPress"
# install WordPress with vars from start of this file.
wp core install --url="http://$projectname.$tld" --title="$projectname" --admin_user="$username" --admin_password="$password" --admin_email="$email"

echo "Block search engines"
# block search engines
wp option set blog_public 0
else
    echo "$(tput setaf 1)WP CLI not installed, skipping WP install$(tput sgr 0)"
fi
read -p "All done, press enter to close..."
