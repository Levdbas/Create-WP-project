#! /bin/bash
# Requirements
# git, yarn, mysql in path, wp-cli and wp-cli-dotenv-command
# install wp-cli with: composer global require wp-cli/wp-cli
# instal dotenv with: wp package install aaemnnosttv/wp-cli-dotenv-command:^1.0
source ./config/variables.config
# moves to htdocs folder
cd
cd $htdocs

read -p "Starting script $(tput setaf 3)$(tput smul)make sure your AMP stack runs before you press enter to continue$(tput sgr 0)"
echo "$(tput setaf 3)Setting up some variables for the install$(tput sgr 0)"

read -p 'Project name (without extention):' projectname
if [ -d "$projectname.$tld" ]; then
  read -p 'Project folder already exists. Exiting.'
  exit
fi
read -p 'Project type (new/existing):' projecttype

if [ "$projecttype" == "new" ]; then
  read -p "Project repository": project_repository
  read -p 'WordPress username:' username
  read -p 'WordPress username password:' password
  read -p 'WordPress user E-Mail:' email
else
  read -p 'Existing project repo adress:' project_repository
fi

echo "$(tput setaf 2)Setting up a $projecttype project in $projectname.$tld$(tput sgr 0)"



# created dir based on project name
  mkdir $projectname.$tld
  cd $projectname.$tld


if [ "$projecttype" == "new" ]; then

  # cloning bedrock and removing unneeded dirs
  echo "$(tput setaf 2)Cloning BedRock $(tput sgr 0)"
  git clone https://github.com/roots/bedrock.git .
  rm -rf .git
  rm -rf .github

  # cloning theme
  echo "$(tput setaf 2)Cloning $theme $(tput sgr 0)"
  git clone $theme $htdocs/$projectname.$tld/web/app/themes/$projectname

  # remove unneeded files
  rm -rf $htdocs/$projectname.$tld/web/app/themes/$projectname/.git
  rm -rf $htdocs/$projectname.$tld/web/app/themes/$projectname/app/composer.json
  rm -rf $htdocs/$projectname.$tld/web/app/themes/$projectname/app/composer.lock

  #move assets / package to root of project.
  mv $htdocs/$projectname.$tld/web/app/themes/$projectname/assets  $htdocs/$projectname.$tld/
  mv $htdocs/$projectname.$tld/web/app/themes/$projectname/.prettierrc  $htdocs/$projectname.$tld/
  mv $htdocs/$projectname.$tld/web/app/themes/$projectname/.stylelintrc  $htdocs/$projectname.$tld/
  mv $htdocs/$projectname.$tld/web/app/themes/$projectname/app/*  $htdocs/$projectname.$tld/web/app/themes/$projectname/
  mv $htdocs/$projectname.$tld/web/app/themes/$projectname/package.json  $htdocs/$projectname.$tld/
  rm -rf $htdocs/$projectname.$tld/web/app/themes/$projectname/app/

  # create repo
  git init

  # add remote
  git remote add origin $project_repository

  # adding node modules to .gitignore
  echo 'node_modules/*' >> .gitignore
  echo '.vscode/*' >> .gitignore
else
   echo "$(tput setaf 2)Cloning your repo$(tput sgr 0)"
   git clone $project_repository .
fi

if grep -q Microsoft /proc/version; then
  mysql --host=127.0.0.1 -u$DBuser -p$DBpassword -e "CREATE DATABASE $projectname"
else
  # create database
  mysql -u$DBuser -p$DBpassword -e "CREATE DATABASE $projectname"
fi

# install dependencies
if yarn --info; then
  echo "$(tput setaf 2)Yarn is installed.$(tput sgr 0)"
  yarn install &
else
  echo "$(tput setaf 3)Yarn isn't installed, falling back to npm install$(tput sgr 0)"
  npm install &
fi

composer install &

# wait for the above three tasks to finish up.
wait

# set browsersync URL in config file.
if [ "$projecttype" == "new" ]; then
  sed -i '2s/.*/"browserSyncURL": "'$projectname.$tld'",/' $htdocs/$projectname.$tld/assets/config.json
  sed -i 's_"app"_"web/app/themes/'$projectname'"_g' $htdocs/$projectname.$tld/assets/config.json
fi

read -p "$(tput setaf 3)Script will try to install WP with WP-cli, add site to your AMP stack before pressing enter to continue$(tput sgr 0)"
# reload host file so browsersync works without a restart.
if grep -q Microsoft /proc/version; then
  sudo cp /mnt/c/Windows/System32/drivers/etc/hosts /etc/hosts
fi
if wp --info; then
  echo "$(tput setaf 2)WP CLI installed, continuing install$(tput sgr 0)"
  echo "Creating .env file"
  wp --allow-root dotenv init --template=.env.example --with-salts
  if grep -q Microsoft /proc/version; then
    read -p "$(tput setaf 3)Uncomment #DB_host and change to 127.0.0.1 before pressing enter to continue$(tput sgr 0)"
  fi
  wp --allow-root dotenv set DB_NAME $projectname
  wp --allow-root dotenv set DB_USER $DBuser
  wp --allow-root dotenv set DB_PASSWORD $DBpassword
  wp --allow-root dotenv set WP_HOME http://$projectname.$tld
  wp --allow-root dotenv set WP_SITEURL http://$projectname.$tld/wp
  if [ "$projecttype" == "new" ]; then
    echo "$(tput setaf 2)Installing WordPress$(tput sgr 0)"
    # install WordPress with vars from start of this file.
    wp core install --url="http://$projectname.$tld" --title="$projectname" --admin_user="$username" --admin_password="$password" --admin_email="$email" --allow-root

    # setting rewrite structure
    wp --allow-root rewrite structure '/%postname%/'

    # setting active theme
    wp --allow-root theme activate $projectname

    wp --allow-root post update 2 --post_title='Home'
    wp --allow-root option update show_on_front 'page'
    wp --allow-root option update page_on_front 2
    wp --allow-root comment delete 1 --force
  fi

else
    read "$(tput setaf 1)WP CLI not installed, skipping WP install$(tput sgr 0)"
fi
echo "running build for the first time"
npm run dev
cd $htdocs/$projectname.$tld
read -p "$(tput setaf 2)All done, moved to project folder root. Happy developing! $(tput sgr 0)"
