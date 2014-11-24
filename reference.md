## Reference

### Command Line Interface

#### Examples:

##### Tagging a Text

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

#### Downloading resources on the fly

You can also download resources on the fly at boot time. This is particularly
interesting when launching a daemon or webservice, but it might also be useful
from the command line.

When given the `--resource-url` option the software will download the file given
(.zip or .tar.gz) into the /tmp folder and extract it into the
`resource-path` folder. Subsequently it will use that resource-path to do
its work.

If the resource has been downloaded before, and it is detected that the
downloaded file is the same as the file on the url location, it will not
download the file again, but will simply re-extract the file.

    cat some-kind-of-kaf.kaf | property-tagger \
      --resource-path ~/resources/property-tagger \
      --resource-url http://some.location.com/property-lexicons.zip

### Webservice

You can launch a webservice by executing:

    property-tagger-server --resource-path /path/to/resources

After launching the server, you can reach the webservice at
<http://localhost:9292>.

The webservice takes several options that get passed along to
[Puma](http://puma.io), the webserver used by the component. The options are:

        -h, --help                Shows this help message
            --puma-help           Shows the options of Puma
        -b, --bucket              The S3 bucket to store output in
            --authentication      An authentication endpoint to use
            --secret              Parameter name for the authentication secret
            --token               Parameter name for the authentication token
            --disable-syslog      Disables Syslog logging (enabled by default)

    Resource Options:

            --resource-url        URL pointing to a .zip/.tar.gz file to download
            --resource-path       Path where the resources should be saved

### Daemon

The daemon has the default OpeNER daemon options. Being:

    Usage: property-tagger-daemon <start|stop|restart> [OPTIONS]

When calling property-tagger without `<start|stop|restart>` the daemon will
start as a foreground process.

Daemon options:

        -h, --help                Shows this help message
        -i, --input               The name of the input queue (default: opener-property-tagger)
        -b, --bucket              The S3 bucket to store output in (default: opener-property-tagger)
        -P, --pidfile             Path to the PID file (default: /var/run/opener/opener-property-tagger-daemon.pid)
        -t, --threads             The amount of threads to use (default: 10)
        -w, --wait                The amount of seconds to wait for the daemon to start (default: 3)
            --disable-syslog      Disables Syslog logging (enabled by default)

    Resource Options:

            --resource-url        URL pointing to a .zip/.tar.gz file to download
            --resource-path       Path where the resources should be saved

#### Environment Variables

These daemons make use of Amazon SQS queues and other Amazon services. For these
services to work correctly you'll need to have various environment variables
set. These are as following:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_REGION`

For example:

    AWS_REGION='eu-west-1' language-identifier start [other options]

### Languages

The property tagger supports the following languages:

* Dutch (nl)
* English (en)
* French (fr)
* German (de)
* Italian (it)
* Spanish (es)
