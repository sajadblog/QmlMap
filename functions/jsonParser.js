    function myFunction(response) {
        var arr = JSON.parse(response);
        for(var i = 0; i < arr.length; i++) {
            listview.model.append( {listdata: arr[i].Name +" "+ arr[i].City +" "+ arr[i].Country })
        }
    }
