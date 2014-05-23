## Reference

### Command Line Interface

#### Examples:

##### Tagging a Text

This application reads a text from standard input in order process it.

    cat some_kind_of_kaf_file.kaf | property-tagger --resource-path /path/to/lexicons/

The property tagger will search in the resource-path for files named
```{language_code}.txt```, for example ```en.txt```.

An excerpt of a potential output would than be:

```
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
```

#### Downloading resources on the fly

You can also download resources on the fly at boot time. This is particularly
interesting when launching a daemon or webservice, but it might also be useful
from the command line.

When given the ```--resource-url``` option the software will download the file
given (.zip or .tar.gz) into the /tmp folder and extract it into the ```resource-path``` folder.
Subsequently it will use that resource-path to do its work.

If the resource has been downloaded before, and it is detected that the
downloaded file is the same as the file on the url location, it will not
download the file again, but will simply re-extract the file.

```
cat some-kind-of-kaf.kaf | property-tagger \
  --resource-path ~/resources/property-tagger \
  --resource-url http://some.location.com/property-lexicons.zip
```

### Webservice

You can launch a webservice by executing:

```
property-tagger-server --resource-path /path/to/resources
```

After launching the server, you can reach the webservice at
<http://localhost:9292>.

The webservice takes several options that get passed along to [Puma](http://puma.io), the
webserver used by the component. The options are:


    -b, --bind URI                   URI to bind to (tcp://, unix://, ssl://)
    -C, --config PATH                Load PATH as a config file
        --control URL                The bind url to use for the control server
                                     Use 'auto' to use temp unix server
        --control-token TOKEN        The token to use as authentication for the control server
    -d, --daemon                     Daemonize the server into the background
        --debug                      Log lowlevel debugging information
        --dir DIR                    Change to DIR before starting
    -e, --environment ENVIRONMENT    The environment to run the Rack app on (default development)
    -I, --include PATH               Specify $LOAD_PATH directories
    -p, --port PORT                  Define the TCP port to bind to
                                     Use -b for more advanced options
        --pidfile PATH               Use PATH as a pidfile
        --preload                    Preload the app. Cluster mode only
        --prune-bundler              Prune out the bundler env if possible
    -q, --quiet                      Quiet down the output
    -R, --restart-cmd CMD            The puma command to run during a hot restart
                                     Default: inferred
    -S, --state PATH                 Where to store the state details
    -t, --threads INT                min:max threads to use (default 0:16)
        --tcp-mode                   Run the app in raw TCP mode instead of HTTP mode
    -V, --version                    Print the version information
    -w, --workers COUNT              Activate cluster mode: How many worker processes to create
        --tag NAME                   Additional text to display in process listing
    -h, --help                       Show help



### Daemon

The daemon has the default OpeNER daemon options. Being:

```
Usage: property-tagger-daemon <start|stop|restart> [options]

When calling property-tagger without <start|stop|restart> the daemon will start as a foreground process

Daemon options:
    -i, --input QUEUE_NAME           Input queue name
    -o, --output QUEUE_NAME          Output queue name
        --batch-size COUNT           Request x messages at once where x is between 1 and 10
        --buffer-size COUNT          Size of input and output buffer. Defaults to 4 * batch-size
        --sleep-interval SECONDS     The interval to sleep when the queue is empty (seconds)
    -r, --readers COUNT              number of reader threads
    -w, --workers COUNT              number of worker thread
    -p, --writers COUNT              number of writer / pusher threads
    -l, --logfile, --log FILENAME    Filename and path of logfile. Defaults to STDOUT
    -P, --pidfile, --pid FILENAME    Filename and path of pidfile. Defaults to /var/run/tokenizer.pid
        --pidpath DIRNAME            Directory where to put the PID file. Is Overwritten by --pid if that option is present
        --debug                      Turn on debug log level
        --relentless                 Be relentless, fail fast, fail hard, do not continue processing when encountering component errors
```

#### Environment Variables

These daemons make use of Amazon SQS queues and other Amazon services.
The access to these services and other environment variables can be configured
using a .opener-daemons-env file in the home directory of the current user.

It is also possible to provide the environment variables directly to the deamon.

For example:

```
AWS_REGION='eu-west-1' property-tagger start [other options]
```

We advise to have the following environment variables available:

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* AWS_REGION

### Languages

That depends on your lexicons. The project will soon open up News lexicons for
the following languages:

* Dutch (nl)
* English (en)
* French (fr)
* German (de)
* Italian (it)
* Spanish (es)
