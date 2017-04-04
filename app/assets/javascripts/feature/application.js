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

    $.ajax({
      method: 'PATCH',
      url: updatePath,
      data: { feature: data },
      success: (response) => {
        updateFeature(box, response.feature)
      },
      failure: (response) => {
        updateFeature(box, response.feature);
      }
    })
  })
};
