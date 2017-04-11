//= require jquery
//= require_tree .

var bindFeatureBoxes = function() {
  var featureBoxes = $('.feature-box');
  for(var box of featureBoxes) {
    bindFeatureBox.call(this, $(box));
  };
}

var updateFeature = function (box, feature) {
  if (feature.type == 'boolean') {

  } else {
    for(var input of box.find('input')) {
      var value = feature.data[input.name]
      input.value = value;
    }
  }
};

var toggleError = function(toggle) {
  if (toggle) {
    $('body .container').append("<div class='loading error'>Error</div>")
  } else {
    $('.loading').remove()
  }
}

var toggleSaving = function(toggle) {
  if (toggle) {
    $('body .container').append("<div class='loading'>Saving...</div>")
  } else {
    $('.loading').remove()
  }
}

var bindFeatureBox = function(box) {
  var featureName = box.data('name')
  var featureType = box.data('type')
  var updatePath = `${window.location.pathname}/features/${featureName}`

  box.find('input').on('change', (e) => {
    var key = e.currentTarget.name
    if (featureType == 'boolean') {
      var value = e.currentTarget.checked
    } else {
      var value = e.currentTarget.value
    }

    var data = {}

    data[key] = value

    toggleSaving(true)

    $.ajax({
      method: 'PATCH',
      url: updatePath,
      data: { feature: data },
      success: (response) => {
        updateFeature(box, response.feature)
        toggleError(false)
        toggleSaving(false)
      },
      error: (response) => {
        toggleSaving(false)
        toggleError(true)
      }
    })
  })
};
