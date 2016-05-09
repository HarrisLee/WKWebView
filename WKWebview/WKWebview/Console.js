console = {
    log: function (string) {
        window.webkit.messageHandlers.OOXX.postMessage({className: 'Console', functionName: 'log', data: string});
    }
}


function hello(string)
{
    alert(string);
}