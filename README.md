# Property Tagger

This module implements a tagger for hotel properties for Dutch, English, French,
Italian, Spanish and German. It detects aspect words, for instance words related
with "room", "cleanliness", "staff" or "breakfast" and links them with the
correct aspect class. The input for this module has to be a valid KAF file with
at lest the term layer, as the lemmas will be used for detecting the hotel
properties. The output is also a KAF valid file extended with the property
layer. This module works for all the languages within the OpeNER project
(en,de,nl,fr,es,it) and the language is read from the input KAF file, from the
lang attribute of the KAF element  (make sure your preprocessors set properly
this value or you might use the resources for a wrong language)

### Confused by some terminology?

This software is part of a larger collection of natural language processing
tools known as "the OpeNER project". You can find more information about the
project at the [OpeNER portal](http://opener-project.github.io). There you can
also find references to terms like KAF (an XML standard to represent linguistic
annotations in texts), component, cores, scenario's and pipelines.

## Quick Use Example

Keep in mind that this component uses PYTHON so it's advised to make sure you
have a virtualenv activated before installing.

Installing the property-tagger can be done by executing:

    gem install opener-property-tagger

Please keep in mind that all components in OpeNER take KAF as an input and
output KAF by default.

### Command line interface

You should now be able to call the property tagger as a regular shell command:
by its name. Once installed the gem normally sits in your path so you can call
it directly from anywhere.

This application reads a text from standard input in order process it.

    cat some_kind_of_kaf_file.kaf | property-tagger --resource-path /path/to/lexicons/

The property tagger will search in the resource-path for files named
`{language_code}.txt`, for example `en.txt`.

An excerpt of a potential output would than be:

    <features>
        <properties>
            <property pid="p1" lemma="cleanliness">
                <references>
                    <!--dirty-->
                    <span>
                        <target id="t_12"/>
                    </span>
                </references>
            </property>
            <property pid="p2" lemma="sleeping_comfort">
                <references>
                    <!--bed-->
                    <span>
                        <target id="t_10"/>
                    </span>
                </references>
            </property>
            <property pid="p3" lemma="staff">
                <references>
                    <!--staff-->
                    <span>
                        <target id="t_16"/>
                    </span>
                    <!--friendly-->
                    <span>
                        <target id="t_20"/>
                    </span>
                </references>
            </property>
        </properties>
    </features>

### Webservices

You can launch a webservice by executing:

    property-tagger-server --resource-path /path/to/resources

This will launch a mini webserver with the webservice. It defaults to port 9292,
so you can access it at <http://localhost:9292>.

To launch it on a different port provide the `-p [port-number]` option like
this:

    property-tagger-server -p 1234

It then launches at <http://localhost:1234>

Documentation on the Webservice is provided by surfing to the urls provided
above. For more information on how to launch a webservice run the command with
the `--help` option.

### Daemon

Last but not least the property tagger comes shipped with a daemon that can read
jobs (and write) jobs to and from Amazon SQS queues. For more information type:

    property-tagger-daemon --help

## Description of dependencies

This component runs best if you run it in an environment suited for OpeNER
components. You can find an installation guide and helper tools in the
[OpeNER installer](https://github.com/opener-project/opener-installer) and an
[installation guide on the Opener Website](http://opener-project.github.io/getting-started/how-to/local-installation.html)

At least you need the following system setup:

### Depenencies for normal use:

* Ruby 1.9.3 or newer
* Python 2.6
* lxml installed
* libarchive (for running the tests and such), on Debian/Ubuntu based systems
  this can be installed using `sudo apt-get install libarchive-dev`

## Domain Adaption and Language Extension

The lexicons in the resource path must be stored in a file and follow this
format:

    surf	verb	facilities
    surfer	noun	facilities
    surfing	verb	facilities

So, one aspect per line, with 3 fields separated by a tabulator, the first one
is the word or span of words (in this case use whitespaces), then the part of
speech (which actually it is not use, you can  include a dummy label) and
finally the aspect class associated with the word.

## The Core

The component is a fat wrapper around the actual language technology core. You
can find the core technolies (python) in the `/core` directory.

## Where to go from here

* [Check the project website](http://opener-project.github.io)
* [Checkout the webservice](http://opener.olery.com/property-tagger)

## Report problem/Get help

If you encounter problems, please email <support@opener-project.eu> or leave an
issue in the
[issue tracker](https://github.com/opener-project/property-tagger/issues).

## Contributing

1. Fork it <http://github.com/opener-project/property-tagger/fork>
2. 2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
