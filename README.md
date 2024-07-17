docker build . -t text_image_guesser_fe

docker run -d -p 5173:5173 --name text_image_guesser_fe -v path_to_file/config.json:/app/src/assets/config.json 

text_image_guesser_fe:latest