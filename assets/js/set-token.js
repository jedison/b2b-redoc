function getParameterByName(name, url = window.location.href) {
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

var token = getParameterByName('token');

if (token) {
    sessionStorage.setItem("redoc.auth.Authorization Token", token)
    window.history.replaceState(null, null, window.location.pathname)
}