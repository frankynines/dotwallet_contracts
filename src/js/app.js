App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    return App.initContract();
  },

  initContract: function() {
    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
  },

  markAdopted: function(adopters, account) {
  },

  handleAdopt: function(event) {
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
