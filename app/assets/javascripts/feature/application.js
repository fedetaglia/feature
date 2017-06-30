//= require jquery
//= require_tree .

var bindFeatureBoxes = function() {
  var featureBoxes = $('.feature-box');
  for(i = 0, i < featureBoxes.lenght; i++) {
    bindFeatureBox($(featureBoxes[i]));
  };
}

var updateFeature = function (box, feature) {
  if (feature.type == 'boolean') {

  } else {
    var inputs = box.find('input')

    for(i = 0, i < inputs.lenght; i++) {
      var value = feature.data[inputs[i].name]
      inputs[i].value = value;
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
  var updatePath = window.location.pathname "/features/" + featureName

  box.find('input').on('change', function(e) {
    var key = e.currentTarget.dataset.key

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
