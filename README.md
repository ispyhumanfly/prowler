# Prowler
A scalable data mining and reporting toolkit for the web.

## Synopsis
Search the world wide web for any URL that matches your query string.

    prowler search detroit+sports
    
Extract specific kinds of data from each page.

Emails
    prowler search detroit+sports | prowler extract emails

Images

    prowler search detroit+sports | prowler extract images

Profiles

    prowler search detroit+sports | prowler extract profiles

Format the results of your search and extraction.

CSV

    prowler search detroit+sports | prowler extract all | prowler format csv

JSON
    
    prowler search detroit+sports | prowler extract all | prowler format json

XML

    prowler search detroit+sports | prowler extract all | prowler format xml

# License
MIT
# Copyright
2017 Dan Stephenson (ispyhumanfly)

