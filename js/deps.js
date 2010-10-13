// the DOM for search.cpan.org isn't easy to parse
// this function recursively finds DOM siblings by tagname
function find_sibling_by_tagname(start, tagname, failsafe, iteration) {
    next = start.nextSibling;
    if ( ! next ) {
        return;
    }
    if ( next.tagName ) {
        if ( next.tagName == failsafe ) {
            return;
        }
        if ( next.tagName == tagname ) {
            if ( ! iteration || iteration == 0 ) {
                return next;
            }
            else {
                iteration = iteration - 1;
            }
        }
    }
    return find_sibling_by_tagname(next, tagname, failsafe, iteration);
}

// this queries the external deps.cpantesters.org for the distribution 
// and counts the number of dependents
// and calls the callback to have the page updated for all modules that are part of the distribution
function gather_cpan_dependents(dist) {
    requestCrossDomain( 'http://deps.cpantesters.org/depended-on-by.pl?dist=' + escape(dist), function(resp) {
        num = '0';
        if ( resp ) {
            num = resp.split('<li>').length-1;
        }
        dependent_counts[dist] = num;
        add_dependents_to_page(dist);
        num_dists_fetched += 1;
        if ( num_dists_fetched == num_dists ) {
            show_top_dists();
        }
    });
}

// this is the callback to update the page
// for the distribution, it updates the page for each module that is part of the distribution
function add_dependents_to_page(dist) {
    for ( var module in infoblocks_by_module ) {
        if ( infoblocks_by_module[module] && dists_by_module[module] == dist ) {
            infoblocks_by_module[module].innerHTML += "(<a href=\"http://deps.cpantesters.org/depended-on-by.pl?dist=" + dists_by_module[module] + "\">CPAN dependents</a>: " + dependent_counts[dist] + ")";
        }
    }
}

// adds the top distrubtions section to the html
function show_top_dists() {
    $('div.t4').css('position', 'relative');
    $('<div />').attr('id', 'top_dists').css({ 'width' : '400px', 'border' : '1px solid #006699', 'position' : 'absolute', 'top' : '40px', 'right' : '0px', 'padding' : '8px', 'font-size' : '12px', 'font-weight' : 'normal', 'color': '#000' }).appendTo('div.t4');
    var txt = '<p style="text-align: center; font-size: 12px; font-weight: bold;">Distributions in order of number of CPAN dependents:<p>';
    dependent_counts = assocSort(dependent_counts);
    for ( var dist in dependent_counts ) {
        txt += '<p>' + dist + ' (' + dependent_counts[dist] + ' dependents)';
        txt += '<br />';
        for ( module in infoblocks_by_module ) {
            if ( infoblocks_by_module[module] && dists_by_module[module] == dist ) {
                txt += '&nbsp;&nbsp;&nbsp;&nbsp;' + module;
            }
        }
        txt += "</p>";
    }
    $("#top_dists").html(txt);
}

// found this function on the interwebs for sorting an associative array by value
function assocSort (oAssoc) {
    var idx; var key; var arVal = []; var arValKey = []; var oRes = {};
    for (key in oAssoc) {
        arVal[arVal.length] = oAssoc[key];
        arValKey[oAssoc[key]] = key;
    }
    arVal.sort().reverse();
    for (idx in arVal)
        oRes[arValKey[arVal[idx]]] = arVal[idx];
    return oRes;
}

// Accepts a url and a callback function to run.
function requestCrossDomain( site, callback ) {

    // If no url was passed, exit.
    if ( !site ) {
        alert('No site was passed.');
        return false;
    }

    // Take the provided url, and add it to a YQL query. Make sure you encode it!
    var yql = 'http://query.yahooapis.com/v1/public/yql?q=' + encodeURIComponent('select * from html where url="' + site + '"') + '&format=xml&callback=?';

    // Request that YSQL string, and run a callback function.
    // Pass a defined function to prevent cache-busting.
    $.getJSON( yql, cbFunc );

    function cbFunc(data) {
        // If we have something to work with...
        if ( data.results[0] ) {
            // Strip out all script tags, for security reasons.
            // BE VERY CAREFUL. This helps, but we should do more.
            data = data.results[0].replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '');
    
            // If the user passed a callback, and it
            // is a function, call it, and send through the data var.
            if ( typeof callback === 'function') {
                callback(data);
            }
        }
        // Else, Maybe we requested a site that doesn't exist, and nothing returned.
        else if (window.console && window.console.log) {
            console.log('Error: Nothing returned from getJSON.');
        }
    }
}
