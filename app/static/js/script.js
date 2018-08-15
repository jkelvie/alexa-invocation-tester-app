$( document ).ready(function() {
  // debounced keyup handler for color checking & autosaving to localStorage
  $('#invocation').on('keyup', _.debounce(function (e) {
    check($(this));
  }, 100));
}); 

$("#form").submit(function(e){
  if ($('#issues').length > 1) { // if there is anything in this div, then we have an issue, so prevent default submit.
    e.preventDefault();
  } else {
    // if everything is fine, go ahead and submit
    $('#loading').html("<p>Please be patient for a few minutes</p>");
    $('#submit').addClass("submitLoading");
    $('#submit').attr("value", " ");
  }
}); 

function twoWords(s){
  var x = s.match(/ the | a | an |for| to | of /gi);
  if (x){console.log(`two word match: ${x}`); return true;} else {return false;}
}  

function alexaKeywords(s){
  var x = s.match(/ open | launch | ask | tell | load | begin | enable | to | from | by | if | whether | news |amazon|alexa|echo|skill| app | update |briefing /gi);
  if (x){console.log(`alexa keyword match: ${x}`);return true;} else {return false;}
}

function problemWords(s){
  var x = s.match(/broadcast|headlines|today|daily| brief |headlines| on |&/gi);
  if (x){console.log(`problem keyword match: ${x}`); return true;} else {return false;}
} 

// length based color checking
function check(e){
  var words = e.val().split(' ');
  var numWords = words.length;
  //console.log(numWords);

  if (numWords === 1 && words[0]){ // less than 2 words?
    $('#issues').html('<span class="red">Must be longer than 1 word</span>');
    $("#submit").addClass("disabled");
  }
  
  else if (numWords === 2 && words[0] && twoWords(" "+words[0]+" ")){ // contains a bad 1st word in 2 word phrase
    $('#issues').html('<span class="red">2 word invocation starts with an article or preposition</span>');
    $("#submit").addClass("disabled");
  }

  else if (words[0] && problemWords(" "+e.val()+" ")){
    $('#issues').html('<span class="red">Contains a keyword that often causes issues</span>');
    $("#submit").addClass("disabled");
  }

  else if (words[0] && alexaKeywords(" "+e.val()+" ")){
    $('#issues').html('<span class="red">Contains a reserved keyword</span>');
    $("#submit").addClass("disabled");
  }

  else {
    $('#issues').html('&nbsp;');
    $("#submit").removeClass("disabled");
  }
  
}

// accordion

$('#accordion').find('.accordion-toggle').click(function(){
  //Expand or collapse this panel
  $(this).next().slideToggle('fast');
  //$(this).toggleClass('accordion-arrow');
  //$(this).toggleClass('.accordion-toggle::before');

  //Hide the other panels
  //$(".accordion-content").not($(this).next()).slideUp('fast');
});