# whatyousay

## What is it?

Simply put, this consolidates chat logs from services such as IRC and talker into a single JSON or HTML document.

Ever wondered what people have been saying about you, but cant be bothered to parse IRC logs? Well now you have no excuse!

## How do i use it?

First make sure you have the required gems, i.e.:

    gem install active_support nokogiri optparse

Then to use, try running:

    ruby whatyousay.rb -t bip -o whattheysaid.json *.log

Which will parse logs as BIP logs and will be dump the results to the whattheysaid.json file.

There are also a few more command-line arguments, i.e.:

    Usage: whatyousay.rb [options] logs
        -t, --logType TYPE               Log Type
        -c, --channel CHANNEL            Set channel
        -o, --output file                Set output
        -h, --help                       Display this screen

Have fun!
