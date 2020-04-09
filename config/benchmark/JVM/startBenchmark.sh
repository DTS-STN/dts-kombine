if type -p java; then
    echo found java executable in PATH
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo found java executable in JAVA_HOME     
    _java="$JAVA_HOME/bin/java"
else
    echo "no java"
fi

if [[ "$_java" ]]; then
    version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo version "$version"
    echo "--------------------"
    sudo javac ./myJar.java > /dev/null
    echo "Starting benchmark in background on port 7777..."
    java -javaagent:agent.jar=port=7777,host=localhost ThreadSleep > /dev/null &
    echo "Type 'kill $(pgrep -n java)' to stop the benchmark."
fi
