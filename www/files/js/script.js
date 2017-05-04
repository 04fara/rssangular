var rssApp = angular.module('rssApp', ['ngRoute', 'ae-datetimepicker']);

rssApp.factory('sharedData', function() {
	const initial = {
		unitname: '',
		unithead: '',
		innomail: '',
		mail: '',
		startdate: '',
		enddate: '',
		courses: [{
			id: 1,
			coname: '',
			cosemester: '',
			codegree: '',
			conumber: 0
		}],
		examinations: [{
			id: 1,
			exname: '',
			exsemester: '',
			exkind: '',
			exnumber: 0
		}],
		revised: [{
			id: 1,
			revname: '',
			revnature: ''
		}],
		reports: [{
			id: 1,
			repname: '',
			reptitle: '',
			repplans: ''
		}],
		theses: [{
			id: 1,
			thename: '',
			thedegree: '',
			thesupervisor: '',
			thecommittee: '',
			theinstitution: '',
			thetitle: ''
		}],
		grants: [{
			id: 1,
			gratitle: '',
			graagency: '',
			graperiod: '',
			graamount: ''
		}],
		rprojects: [{
			id: 1,
			rptitle: '',
			rpinno: '',
			rpext: '',
			rpstart: '',
			rpend: '',
			rpinvest: ''
		}],
		rcollab: [{
			id: 1,
			rccountry: '',
			rcinstitution: '',
			rcprincipal: '',
			rcnature: ''
		}],
		conference: [{
			id: 1,
			confauthor: '',
			confpubl: ''
		}],
		journal: [{
			id: 1,
			jauthor: '',
			jpubl: ''
		}],
		awards: [{
			id: 1,
			awauthor: '',
			awtitle: '',
			awassoc: '',
			awwording: '',
			awdate: ''
		}],
		member: [{
			id: 1,
			memname: '',
			memdate: ''
		}],
		prizes: [{
			id: 1,
			prrec: '',
			prprize: '',
			prinst: '',
			prdate: ''
		}],
		icollab: [{
			id: 1,
			icomp: '',
			inature: ''
		}],
		patents: '',
		licensing: '',
		additional: ''
	};
	var forms = angular.copy(initial);
	return {
		forms,
		initial
	};
});

rssApp.controller('NavigationController', function($scope, $http, sharedData) {
	$scope.states = {};
	$scope.states.activeItem = 1;
	$scope.states.activeQuery = -1;
	$scope.states.activeLab = '';
	$scope.initial = angular.copy(sharedData.initial);
	$scope.forms = sharedData.forms;
	$scope.validity = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
	$scope.submitted = false;
	$scope.response;
	$scope.query = {
		query: -1,
		params: {
			lab: "",
			startdate: null,
			enddate: null
		},
	}
	$scope.postData = function() {
		$http.post('sending', $scope.forms).then(
			function(success) {
				$scope.submitted = true;
			});
	}
	$scope.getData = function() {
		$http.post('receiving', $scope.query).then(
			function(success) {
				$scope.response = JSON.parse(JSON.stringify(success));
			});
	}
	$scope.getLabsList = function() {
		$http.post('receiving', $scope.query).then(
			function(success) {
				$scope.tmp = JSON.parse(JSON.stringify(success));
				$scope.labs = [];
				for (var i = 0; i < $scope.tmp.data.values.length; i++) {
					$scope.labs = $scope.labs.concat($scope.tmp.data.values[i][0]);
				}
			});
	}
	$scope.resetData = function() {
		$scope.submitted = false;
		$scope.response = "";
		$scope.validity = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
		angular.copy(sharedData.initial, sharedData.forms);
		$scope.resetQueryParams();
		$scope.states.activeQuery = -1;
		$scope.query.query = -1;
	}
	$scope.resetQueryParams = function() {
		$scope.query.params = {
			lab: "",
			startdate: null,
			enddate: null
		};
		$scope.states.activeLab = '';
	}
	$scope.checkAdmin = function() {
		bool = false;
		switch ($scope.query.query) {
			case 1:
			case 5:
			case 6:
			bool = true;
			break;
			case 2:
			case 7:
			if ($scope.query.params.hasOwnProperty("lab") && $scope.query.params.hasOwnProperty("startdate") && $scope.query.params.hasOwnProperty("enddate") && $scope.query.params.startdate >= 1960 && $scope.query.params.enddate > $scope.query.params.startdate) bool = true;
			break;
			case 3:
			if ($scope.query.params.hasOwnProperty("lab")) bool = true;
			break;
			case 4:
			if ($scope.query.params.hasOwnProperty("startdate") && $scope.query.params.hasOwnProperty("enddate") && $scope.query.params.startdate >= 1960 && $scope.query.params.enddate > $scope.query.params.startdate) bool = true;
			break;
		}
		return bool;
	}
	$scope.checkValidity = function(i, val) {
		$scope.validity[i] = val;
	}
	$scope.sections = [{
		id: 1,
		title: 'General',
		href: 'section1'
	}, {
		id: 2,
		title: 'Teaching',
		href: 'section2'
	}, {
		id: 3,
		title: 'Research',
		href: 'section3'
	}, {
		id: 4,
		title: 'Technology transfer',
		href: 'section4'
	}, {
		id: 5,
		title: 'Achievements',
		href: 'section5'
	}, {
		id: 6,
		title: 'Outside activities',
		href: 'section6'
	}, {
		id: 7,
		title: 'Additional',
		href: 'section7'
	}, {
		id: 8,
		title: 'Overall',
		href: 'overall'
	}, ];
	$scope.queries = [{
		id: 1,
		title: 'List all existing laboratories and the number of reports each of them have submitted'
	}, {
		id: 2,
		title: 'Show an information of a unit over several years'
	}, {
		id: 3,
		title: 'List all publications of laboratory'
	}, {
		id: 4,
		title: 'List all publications of university'
	}, {
		id: 5,
		title: 'Show the number of research collaborations'
	}, {
		id: 6,
		title: 'Show the number of supervised students'
	}, {
		id: 7,
		title: 'List the courses taught by laboratory'
	}];

});

rssApp.controller('DataController', function($scope) {
	$scope.addCo = function() {
		var newItemNo = $scope.forms.courses.length + 1;
		var newItem = angular.copy($scope.initial.courses[0]);
		newItem['id'] = newItemNo;
		$scope.forms.courses.push(newItem);
	};
	$scope.addEx = function() {
		var newItemNo = $scope.forms.examinations.length + 1;
		var newItem = angular.copy($scope.initial.examinations[0]);
		newItem['id'] = newItemNo;
		$scope.forms.examinations.push(newItem);
	};
	$scope.addRev = function() {
		var newItemNo = $scope.forms.revised.length + 1;
		var newItem = angular.copy($scope.initial.revised[0]);
		newItem['id'] = newItemNo;
		$scope.forms.revised.push(newItem);
	};
	$scope.addRep = function() {
		var newItemNo = $scope.forms.reports.length + 1;
		var newItem = angular.copy($scope.initial.reports[0]);
		newItem['id'] = newItemNo;
		$scope.forms.reports.push(newItem);
	};
	$scope.addThe = function() {
		var newItemNo = $scope.forms.theses.length + 1;
		var newItem = angular.copy($scope.initial.theses[0]);
		newItem['id'] = newItemNo;
		$scope.forms.theses.push(newItem);
	};
	$scope.addGra = function() {
		var newItemNo = $scope.forms.grants.length + 1;
		var newItem = angular.copy($scope.initial.grants[0]);
		newItem['id'] = newItemNo;
		$scope.forms.grants.push(newItem);
	};
	$scope.addRp = function() {
		var newItemNo = $scope.forms.rprojects.length + 1;
		var newItem = angular.copy($scope.initial.rprojects[0]);
		newItem['id'] = newItemNo;
		$scope.forms.rprojects.push(newItem);
	};
	$scope.addRc = function() {
		var newItemNo = $scope.forms.rcollab.length + 1;
		var newItem = angular.copy($scope.initial.rcollab[0]);
		newItem['id'] = newItemNo;
		$scope.forms.rcollab.push(newItem);
	};
	$scope.addConf = function() {
		var newItemNo = $scope.forms.conference.length + 1;
		var newItem = angular.copy($scope.initial.conference[0]);
		newItem['id'] = newItemNo;
		$scope.forms.conference.push(newItem);
	};
	$scope.addJ = function() {
		var newItemNo = $scope.forms.journal.length + 1;
		var newItem = angular.copy($scope.initial.journal[0]);
		newItem['id'] = newItemNo;
		$scope.forms.journal.push(newItem);
	};
	$scope.addAw = function() {
		var newItemNo = $scope.forms.awards.length + 1;
		var newItem = angular.copy($scope.initial.awards[0]);
		newItem['id'] = newItemNo;
		$scope.forms.awards.push(newItem);
	};
	$scope.addMem = function() {
		var newItemNo = $scope.forms.member.length + 1;
		var newItem = angular.copy($scope.initial.member[0]);
		newItem['id'] = newItemNo;
		$scope.forms.member.push(newItem);
	};
	$scope.addPri = function() {
		var newItemNo = $scope.forms.prizes.length + 1;
		var newItem = angular.copy($scope.initial.prizes[0]);
		newItem['id'] = newItemNo;
		$scope.forms.prizes.push(newItem);
	};
	$scope.addIc = function() {
		var newItemNo = $scope.forms.icollab.length + 1;
		var newItem = angular.copy($scope.initial.icollab[0]);
		newItem['id'] = newItemNo;
		$scope.forms.icollab.push(newItem);
	};

	$scope.removeCo = function(id) {
		$scope.forms.courses.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.courses.length; i++) {
			$scope.forms.courses[i].id--;
		}
	};
	$scope.removeEx = function(id) {
		$scope.forms.examinations.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.examinations.length; i++) {
			$scope.forms.examinations[i].id--;
		}
	};
	$scope.removeRev = function(id) {
		$scope.forms.revised.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.revised.length; i++) {
			$scope.forms.revised[i].id--;
		}
	};
	$scope.removeRep = function(id) {
		$scope.forms.reports.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.reports.length; i++) {
			$scope.forms.reports[i].id--;
		}
	};
	$scope.removeThe = function(id) {
		$scope.forms.theses.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.theses.length; i++) {
			$scope.forms.theses[i].id--;
		}
	};
	$scope.removeGra = function(id) {
		$scope.forms.grants.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.grants.length; i++) {
			$scope.forms.grants[i].id--;
		}
	};
	$scope.removeRp = function(id) {
		$scope.forms.rprojects.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.rprojects.length; i++) {
			$scope.forms.rprojects[i].id--;
		}
	};
	$scope.removeRc = function(id) {
		$scope.forms.rcollab.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.rcollab.length; i++) {
			$scope.forms.rcollab[i].id--;
		}
	};
	$scope.removeConf = function(id) {
		$scope.forms.conference.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.conference.length; i++) {
			$scope.forms.conference[i].id--;
		}
	};
	$scope.removeJ = function(id) {
		$scope.forms.journal.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.journal.length; i++) {
			$scope.forms.journal[i].id--;
		}
	};
	$scope.removeAw = function(id) {
		$scope.forms.awards.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.awards.length; i++) {
			$scope.forms.awards[i].id--;
		}
	};
	$scope.removeMem = function(id) {
		$scope.forms.member.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.member.length; i++) {
			$scope.forms.member[i].id--;
		}
	};
	$scope.removePri = function(id) {
		$scope.forms.prizes.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.prizes.length; i++) {
			$scope.forms.prizes[i].id--;
		}
	};
	$scope.removeIc = function(id) {
		$scope.forms.icollab.splice(id - 1, 1);
		for (var i = id - 1; i < $scope.forms.icollab.length; i++) {
			$scope.forms.icollab[i].id--;
		}
	};

	$scope.check = function(dict) {
		var boo = true;
		angular.forEach(dict, function(value, key) {
			if (boo)
				if (value == "")
					boo = false;
			});
		return boo;
	};

	$scope.isNumber = function(value) {
		return angular.isNumber(value);
	}
	
});

rssApp.controller('DatesController', function() {
	var dates = this;
	dates.optionsFrom = {
		format: 'DD/MM/YYYY',
		useCurrent: false,
		widgetPositioning: {
			horizontal: 'right'
		}
	};
	dates.optionsTo = {
		format: 'DD/MM/YYYY',
		useCurrent: false,
		widgetPositioning: {
			horizontal: 'right'
		}
	};
	dates.update = function(dateFrom, dateTo) {
		dates.optionsFrom.maxDate = dateTo;
		dates.optionsTo.minDate = dateFrom;
	};
});

rssApp.config(function($routeProvider, $locationProvider) {
	$routeProvider

	.when('/main', {
		templateUrl: 'files/pages/main.html',
		controller: 'mController'
	})

	.when('/admin', {
		templateUrl: 'files/pages/admin.html',
		controller: 'aController'
	})

	.when('/section1', {
		controller: 'NavigationController'
	})

	.when('/section1', {
		templateUrl: 'files/pages/section1.html',
		controller: 's1Controller'
	})

	.when('/section2', {
		controller: 'NavigationController'
	})

	.when('/section2', {
		templateUrl: 'files/pages/section2.html',
		controller: 's2Controller'
	})

	.when('/section3', {
		controller: 'NavigationController'
	})

	.when('/section3', {
		templateUrl: 'files/pages/section3.html',
		controller: 's3Controller'
	})

	.when('/section4', {
		controller: 'NavigationController'
	})

	.when('/section4', {
		templateUrl: 'files/pages/section4.html',
		controller: 's4Controller'
	})

	.when('/section5', {
		controller: 'NavigationController'
	})

	.when('/section5', {
		templateUrl: 'files/pages/section5.html',
		controller: 's5Controller'
	})

	.when('/section6', {
		controller: 'NavigationController'
	})

	.when('/section6', {
		templateUrl: 'files/pages/section6.html',
		controller: 's6Controller'
	})

	.when('/section7', {
		controller: 'NavigationController'
	})

	.when('/section7', {
		templateUrl: 'files/pages/section7.html',
		controller: 's7Controller'
	})

	.when('/overall', {
		templateUrl: 'files/pages/overall.html',
		controller: 'overallController'
	})

	.otherwise('/main');

	$locationProvider.hashPrefix('');
	$locationProvider.html5Mode(true);
});

rssApp.controller('mController', function($scope) {
	$scope.states.activeItem = 0;
});

rssApp.controller('aController', function($scope) {
	$scope.states.activeItem = -1;
});

rssApp.controller('s1Controller', function($scope) {
	$scope.states.activeItem = 1;
});

rssApp.controller('s2Controller', function($scope) {
	$scope.states.activeItem = 2;
});

rssApp.controller('s3Controller', function($scope) {
	$scope.states.activeItem = 3;
});

rssApp.controller('s4Controller', function($scope) {
	$scope.states.activeItem = 4;
});

rssApp.controller('s5Controller', function($scope) {
	$scope.states.activeItem = 5;
});

rssApp.controller('s6Controller', function($scope) {
	$scope.states.activeItem = 6;
});

rssApp.controller('s7Controller', function($scope) {
	$scope.states.activeItem = 7;
});

rssApp.controller('overallController', function($scope) {
	$scope.states.activeItem = 8;
});

$(document).click(function(e) {
	if (!$(e.target).is('a') || $(e.target).is('a')) {
		$('.btn').blur();
		$('.navbar-collapse').collapse('hide');
	}
});