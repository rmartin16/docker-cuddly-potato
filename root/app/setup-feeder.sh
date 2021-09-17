#!/usr/bin/env sh
set -euf

echo "Setting up cuddly potato..."

# Set up podcaste assets directory
mkdir -p /data/podcast-assets

# Download cuddly-potato
if ! [ -d "/data/cuddly-potato" ]; then
    cd /data
    echo "Pulling from github..."
    git clone https://github.com/rmartin16/cuddly-potato.git
fi
cd /data/cuddly-potato
echo "Checking out branch "$GITBRANCH"..."
git checkout $GITBRANCH
git pull --rebase

# Prepare and activate venv
echo "Activating "$(python -V)" virtual environment..."
mkdir -p venv
python -m venv --upgrade venv
python -m venv venv
. venv/bin/activate

# Make sure we are in the venv
[ -n "${VIRTUAL_ENV:-}" ]

# Update pip tools
echo "Updating Pip tools..."
python -m pip install -U pip wheel setuptools

# Install and configure cuddly potato
echo "Installing cuddly potato..."
python -m pip install -e .
echo "Configuring database..."
python manage.py migrate
echo "Creating superuser..."
export DJANGO_SUPERUSER_USERNAME="$ADMIN_USERNAME"
export DJANGO_SUPERUSER_PASSWORD="$ADMIN_PASSWORD"
export DJANGO_SUPERUSER_EMAIL="$ADMIN_EMAIL"
set +e
python manage.py createsuperuser --no-input
set -e
echo "Collecting static files..."
python manage.py collectstatic --clear --noinput
