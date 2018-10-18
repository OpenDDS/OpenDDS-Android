set -e

cp travis_template.yml .travis.yml
python3 matrix.py travis >> .travis.yml

echo "set -e" > shell_matrix.sh
echo >> shell_matrix.sh
python3 matrix.py shell >> shell_matrix.sh
