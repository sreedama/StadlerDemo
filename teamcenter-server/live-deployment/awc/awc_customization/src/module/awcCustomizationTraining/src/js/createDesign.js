// Copyright (c) 2022 Siemens

/**
 * @module js/createDesign
 */
import _ from 'lodash';
import colorDecoratorSvc from 'js/colorDecoratorService';

var exports = {};

export let assignValue = function( assignValue, updatePlace, property ) {
    updatePlace[ property ] = assignValue;
};

export let returnValue = function( assignValue, updatePlace, property ) {
    updatePlace = _.cloneDeep( updatePlace );
    updatePlace[ property ] = assignValue;
    return updatePlace;
};

export let getAvailablePages = function( startIndex, pageSize, filterString, includePreferredChoices ) {
    var listBox1Values = [ {
        propDisplayValue: 'New York',
        propInternalValue: 'New_York'
    },
    {
        propDisplayValue: 'California',
        propInternalValue: 'California'
    },
    {
        propDisplayValue: 'Illinois',
        propInternalValue: 'Illinois'
    },
    {
        propDisplayValue: 'Texas',
        propInternalValue: 'Texas'
    },
    {
        propDisplayValue: 'Pennsylvania',
        propInternalValue: 'Pennsylvania'
    },
    {
        propDisplayValue: 'Arizona',
        propInternalValue: 'Arizona'
    },
    {
        propDisplayValue: 'Florida',
        propInternalValue: 'Florida'
    },
    {
        propDisplayValue: 'Indiana',
        propInternalValue: 'Indiana'
    },
    {
        propDisplayValue: 'Ohio',
        propInternalValue: 'Ohio'
    },
    {
        propDisplayValue: 'North Carolina',
        propInternalValue: 'North_Carolina'
    },
    {
        propDisplayValue: 'Michigan',
        propInternalValue: 'Michigan'
    },
    {
        propDisplayValue: 'Tennessee',
        propInternalValue: 'Tennessee'
    },
    {
        propDisplayValue: 'Massachusetts',
        propInternalValue: 'Massachusetts'
    },
    {
        propDisplayValue: 'Washington',
        propInternalValue: 'Washington'
    },
    {
        propDisplayValue: 'Colorado',
        propInternalValue: 'Colorado'
    },
    {
        propDisplayValue: 'District of Columbia',
        propInternalValue: 'District_of_Columbia'
    },
    {
        propDisplayValue: 'Maryland',
        propInternalValue: 'Maryland'
    },
    {
        propDisplayValue: 'Kentucky',
        propInternalValue: 'Kentucky'
    },
    {
        propDisplayValue: 'Oregon',
        propInternalValue: 'Oregon'
    },
    {
        propDisplayValue: 'Oklahoma',
        propInternalValue: 'Oklahoma'
    },
    {
        propDisplayValue: 'Wisconsin',
        propInternalValue: 'Wisconsin'
    },
    {
        propDisplayValue: 'Nevada',
        propInternalValue: 'Nevada'
    },
    {
        propDisplayValue: 'New Mexico',
        propInternalValue: 'New Mexico'
    },
    {
        propDisplayValue: 'Missouri',
        propInternalValue: 'Missouri'
    },
    {
        propDisplayValue: 'Virginia',
        propInternalValue: 'Virginia'
    },
    {
        propDisplayValue: 'Georgia',
        propInternalValue: 'Georgia'
    },
    {
        propDisplayValue: 'Nebraska',
        propInternalValue: 'Nebraska'
    },
    {
        propDisplayValue: 'Minnesota',
        propInternalValue: 'Minnesota'
    },
    {
        propDisplayValue: 'Kansas',
        propInternalValue: 'Kansas'
    },
    {
        propDisplayValue: 'Louisiana',
        propInternalValue: 'Louisiana'
    },
    {
        propDisplayValue: 'Hawaii',
        propInternalValue: 'Hawaii'
    },
    {
        propDisplayValue: 'Alaska',
        propInternalValue: 'Alaska'
    },
    {
        propDisplayValue: 'New Jersey',
        propInternalValue: 'New Jersey'
    },
    {
        propDisplayValue: 'Idaho',
        propInternalValue: 'Idaho'
    },
    {
        propDisplayValue: 'Alabama',
        propInternalValue: 'Alabama'
    },
    {
        propDisplayValue: 'Iowa',
        propInternalValue: 'Iowa'
    },
    {
        propDisplayValue: 'Arkansas',
        propInternalValue: 'Arkansas'
    },
    {
        propDisplayValue: 'Utah',
        propInternalValue: 'Utah'
    },
    {
        propDisplayValue: 'Rhode Island',
        propInternalValue: 'Rhode_Island'
    },
    {
        propDisplayValue: 'Mississippi',
        propInternalValue: 'Mississippi'
    },
    {
        propDisplayValue: 'South Dakota',
        propInternalValue: 'South_Dakota'
    },
    {
        propDisplayValue: 'Connecticut',
        propInternalValue: 'Connecticut'
    },
    {
        propDisplayValue: 'South Carolina',
        propInternalValue: 'South_Carolina'
    },
    {
        propDisplayValue: 'New Hampshire',
        propInternalValue: 'New_Hampshire'
    },
    {
        propDisplayValue: 'North Dakota',
        propInternalValue: 'North_Dakota'
    },
    {
        propDisplayValue: 'Montana',
        propInternalValue: 'Montana'
    },
    {
        propDisplayValue: 'Delaware',
        propInternalValue: 'Delaware'
    },
    {
        propDisplayValue: 'Maine',
        propInternalValue: 'Maine'
    },
    {
        propDisplayValue: 'Wyoming',
        propInternalValue: 'Wyoming'
    },
    {
        propDisplayValue: 'West Virginia',
        propInternalValue: 'West_Virginia'
    },
    {
        propDisplayValue: 'Vermont',
        propInternalValue: 'Vermont'
    }
    ];

    let objectValue = {};
    if( filterString && filterString.trim() !== '' ) {
        listBox1Values = listBox1Values.filter( function( listVal ) {
            return listVal.propInternalValue.toLowerCase().indexOf( filterString.toLowerCase() ) !== -1 ||
                listVal.propDisplayValue.toLowerCase().indexOf( filterString.toLowerCase() ) !== -1;
        } );
        startIndex = startIndex ? startIndex : 0;
        let endIndex = parseInt( startIndex + parseInt( pageSize ) );
        objectValue.pageList = listBox1Values.slice( startIndex, endIndex );
        objectValue.totalFound = listBox1Values.length;
    } else {
        startIndex = startIndex ? startIndex : 0;
        let endIndex = parseInt( startIndex + parseInt( pageSize ) );
        objectValue.pageList = listBox1Values.slice( startIndex, endIndex );
        objectValue.totalFound = listBox1Values.length;
    }

    // define 2 preferred vals - optional
    if( includePreferredChoices ) {
        objectValue.preferredChoices = [
            {
                propDisplayValue: 'Wisconsin',
                propInternalValue: 'Wisconsin'
            },
            {
                propDisplayValue: 'Nevada',
                propInternalValue: 'Nevada'
            }
        ];
    }

    return new Promise( function( resolve ) {
        setTimeout( function() {
            resolve( objectValue );
        }, 1000 );
    } );
};

export let getPreferredUSStates = function() {
    // define 2 preferred vals
    let returnObj = {
        preferredChoices: [
            { propDisplayValue: 'West Virginia', propInternalValue: 'West_Virginia' },
            { propDisplayValue: 'Vermont', propInternalValue: 'Vermont' }
        ]
    };

    // simulate a network situation
    return new Promise( function( resolve ) {
        setTimeout( function() {
            resolve( returnObj );
        }, 1000 );
    } );
};

export const updateLabel = ( eventData ) => {
    if( eventData && eventData.newPattern ) {
        return eventData.newPattern;
    }
};

export const getFilteredMoviesList = function( response, filterString ) {
    let listBox4Values = response.data.search;
    if( filterString && filterString.trim() !== '' ) {
        listBox4Values = listBox4Values.filter( ( listVal ) => {
            return listVal.propInternalValue.toLowerCase().indexOf( filterString.toLowerCase() ) !== -1 ||
                listVal.propDisplayValue.toLowerCase().indexOf( filterString.toLowerCase() ) !== -1;
        } );
        return listBox4Values;
    }
    return listBox4Values;
};

export const getlistBox3FilteredList = function( response, filterString ) {
    let listBox4Values = response.vals;
    if( filterString && filterString.trim() !== '' ) {
        listBox4Values = listBox4Values.filter( ( listVal ) => {
            return listVal.propInternalValue.toLowerCase().indexOf( filterString.toLowerCase() ) !== -1 ||
                listVal.propDisplayValue.toLowerCase().indexOf( filterString.toLowerCase() ) !== -1;
        } );
        return listBox4Values;
    }
    return listBox4Values;
};

export const getList = async function( list ) {
    return new Promise( function( resolve ) {
        setTimeout( function() {
            resolve( list );
        }, 1000 );
    } );
};

export const checkRomance = function( vmo ) {
    console.log( 'checkRomance vmo: ', vmo );
    if( vmo.Type === 'Romance' ) {
        return true;
    }
};

export const checkFiction = function( vmo ) {
    console.log( 'checkFiction vmo: ', vmo );
    if( vmo.Type === 'Fiction' ) {
        return true;
    }
};

export let getSearchResults = function( data ) {
    let result = data.data.Search;
    if( result ) {
        _.forEach( result, function( obj ) {
            colorDecoratorSvc.setDecoratorStyles( obj, true );
        } );
    }
    return result;
};

/**
 * Since this module can be loaded as a dependent DUI module we need to return an object indicating which service
 * should be injected to provide the API for this module.
 */
export let moduleServiceNameToInject = 'mathUtils';
export default exports = {
    assignValue,
    returnValue,
    moduleServiceNameToInject,
    getAvailablePages,
    getPreferredUSStates,
    updateLabel,
    getFilteredMoviesList,
    getlistBox3FilteredList,
    getList,
    checkRomance,
    checkFiction,
    getSearchResults
};
