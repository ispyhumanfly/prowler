# Prowler
A scalable data mining and reporting toolkit for the web.

## Synopsis
Search the world wide web for any URL that matches your query string.

    prowler search detroit+sports
    
Extract specific kinds of data from each page.

    prowler search detroit+sports | prowler extract email

Or

    prowler search detroit+sports | prowler extract images

Or

    prowler search detroit+sports | prowler extract profiles

Format the results of your search and extraction.

    prowler search detroit+sports | prowler extract all | prowler format csv

Or
    
    prowler search detroit+sports | prowler extract all | prowler format json

Or
    prowler search detroit+sports | prowler extract all | prowler format xml

# License
MIT
# Copyright
2017 Dan Stephenson (ispyhumanfly)

