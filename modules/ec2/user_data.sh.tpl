#!/bin/bash

# 必要な権限設定
chown -R ec2-user:ec2-user /var/www/todo-app-backend
chmod -R 755 /var/www/todo-app-backend

# ec2-userがAWS CLIを使えるようにする
sudo -u ec2-user aws configure set region ${region}

# ec2-userとしてアプリケーションを起動
sudo -u ec2-user bash << 'EOF'
export HOME=/home/ec2-user
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
eval "$($RBENV_ROOT/bin/rbenv init -)"

cd ${project_path}

DB_PASSWORD=$(aws ssm get-parameter --name "/${project_name}/${environment}/app/MYSQL_PASSWORD" --with-decryption --query "Parameter.Value" --output text --region ${region})
DB_HOST=${db_host}

echo "Waiting for RDS to be ready..."
until nc -z "$DB_HOST" 3306; do
  echo "Still waiting for RDS..."
  sleep 10
done
echo "RDS is ready!"

cat > .env << EOL
DB_HOST=${db_host}
DB_PASSWORD=$DB_PASSWORD
DB_USERNAME=${db_username}
DB_NAME=${db_name}
USER_POOL_ID=${user_pool_id}
AWS_REGION=${region}
ALLOWED_HOST=${allowed_host}
EOL

rm -f tmp/pids/server.pid

bundle exec rails db:create || true
bundle exec rails db:migrate
echo "DB setup is complete!"

bundle exec rails s -b 0.0.0.0 -p 3000 > log/development.log 2>&1 &

EOF
