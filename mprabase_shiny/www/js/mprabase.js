/*Shiny handlers*/

const browseUrl = url => {
  window.open(url, "_blank");
};

Shiny.addCustomMessageHandler("handler_browseUrl", browseUrl);

/*Global variables*/
let STANDARD_SAMPLES_SELECTED_ENTRIES = [];
let SYNTHETIC_SAMPLES_SELECTED_ENTRIES = [];

/*checkbox update functions*/
function samples_updateSelected(synthetic=false) {
  
  var samples_checkid = 'standard_samples_check[]';
  var selected_entries = STANDARD_SAMPLES_SELECTED_ENTRIES;
  var shiny_input_id = 'STANDARD_SAMPLE_ID';
  
  if(synthetic == true) {
    samples_checkid = 'synthetic_samples_check[]';
    selected_entries = SYNTHETIC_SAMPLES_SELECTED_ENTRIES;
    shiny_input_id = 'SYNTHETIC_SAMPLE_ID';
  }
  
  var  tx = document.getElementsByName(samples_checkid);
  var values = [];
  for (var i=0; i < tx.length; i+=1) {
    if (selected_entries.includes(tx[i].value)) {
      if(tx[i].checked == true) {
        console.log(tx[i].value + " already in global");
      }
      
      else {
        var index = selected_entries.indexOf(tx[i].value);
        var removed = selected_entries.splice(index, 1);
      }
    }
    else {
      if(tx[i].checked == true) {
      selected_entries.push(tx[i].value);
      }
    }
  }
  if(selected_entries.length > 0) {
    var values_str = selected_entries.join(",");
   }
  else {
     var values_str = null;
   }
  Shiny.setInputValue(shiny_input_id, values_str, {priority: "event"});
  return true;
}

function datasets_updateSelected(synthetic=false) {
     var datasets_checkid = 'standard_datasets_check[]';
     var shiny_input_id = 'STANDARD_DATASET_SELECTED_ID';
     if(synthetic == true) {
       datasets_checkid = 'synthetic_datasets_check[]';
       shiny_input_id = 'SYNTHETIC_DATASET_SELECTED_ID';
     }
  
     var  tx = document.getElementsByName(datasets_checkid);
        var values = [];
    for(var i=0; i < tx.length; i +=1) {
      if (tx[i].checked == true) {
        values.push(tx[i].value);
      }
    }
   if(values.length > 0) {
    var values_str = values.join(",");
   }
   else {
     var values_str = null;
   }
    Shiny.setInputValue(shiny_input_id, values_str, {priority: "event"});
    return true;
}

/*Download images code*/

function downloadImage(img_id, download_name) {
    var svg=document.getElementById(img_id).getElementsByTagName('svg')[0];
    var xml = new XMLSerializer().serializeToString(svg);
    var svg64 = btoa(unescape(encodeURIComponent(xml)));
    var b64Start = 'data:image/svg+xml;base64,';
    var image64 = b64Start + svg64;
    
    var img = document.createElement('img');
    img.src = image64;

  img.onload = function() {
    var canvas = document.createElement('canvas');
    canvas.width = img.width;
    canvas.height = img.height;
    var context = canvas.getContext('2d');
    context.drawImage(img, 0, 0);
    
    var a = document.createElement('a');
    a.download = download_name + ".png";
    a.href = canvas.toDataURL('image/png');
    document.body.appendChild(a);
    a.click();
  }

  var event = document.createEvent('Event');
  event.initEvent('click', true, true);
  save.dispatchEvent(event);
  (window.URL || window.webkitURL).revokeObjectURL(save.href);
   
}