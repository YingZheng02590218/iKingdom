var dataStuff = {};
var loopLimit = 2;
var currentLoop = 1;
var stopFrameAnimation = false;
var legalDuration = 4000;

var ctaBtnY = 0;
var cLine1 = {};
var tl;
var tlComplete = false;
var boxWidth = 220;
var boxHeight = 150;
var stopTimeline = false;
var loadDynamicData = true;
var marketLeft = 0;

var timing = {
    f1sec:3,
    f2sec:3,
    f3sec:3,
    lsec:3
}
var ctaAnimationStyle = 0;

function pageLoadedHandler() {
	if(loadDynamicData){ 
        populateData();
    }else{
        updatePosition();
        initBanner();
    }
	setListeners();
}

function populateData(){
    
	// Dynamic Content variables and sample values
    Enabler.setProfileId(1098250);
    var devDynamicContent = {};

    devDynamicContent.JP_Volatility_Templates_Sheet1= [{}];
    devDynamicContent.JP_Volatility_Templates_Sheet1[0]._id = 0;
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].ID = 1;
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].MESSAGE_NAME = "FTSE100";
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].BANNER_CODE = "size=300x250||market=FTSE100||marketFS=25||msg1=is%20moving%20now||msg1FS=25||msg2=Find%20a%20trade%20with%20live%20data%20and%20analysis||msg2FS=25||ctaBtn=Find%20your%20trade||ctaBtnFS=12||legal=||legalFS=12||disclaimer=Losses%20can%20exceed%20deposits||disclaimerFS=12||loop=2||ctaAnimation=0||f1sec=0||f2sec=3||lsec=3";
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].CLICKTHROUGH = {};
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].CLICKTHROUGH.Url = "https://www.ig.com/";
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].CTA_CLICKTHROUGH = {};
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].CTA_CLICKTHROUGH.Url = "https://www.ig.com/";
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].START_DATE = {};
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].START_DATE.RawValue = "";
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].START_DATE.UtcValue = 0;
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].END_DATE = {};
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].END_DATE.RawValue = "";
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].END_DATE.UtcValue = 0;
    devDynamicContent.JP_Volatility_Templates_Sheet1[0].DEFAULT = false;
    Enabler.setDevDynamicContent(devDynamicContent);
	
	dataStuff = parseBannerCode(dynamicContent.JP_Volatility_Templates_Sheet1[0].BANNER_CODE);


	document.getElementById('market').lastElementChild.innerHTML = dataStuff.market;
    document.getElementById('market').lastElementChild.style.fontSize = dataStuff.marketFS+"px";

	document.getElementById('line1').lastElementChild.innerHTML = dataStuff.msg1;
	document.getElementById('line1').lastElementChild.style.fontSize = dataStuff.msg1FS+"px";
	document.getElementById('line2').lastElementChild.innerHTML = dataStuff.msg2;
	document.getElementById('line2').lastElementChild.style.fontSize = dataStuff.msg2FS+"px";
	document.getElementById('line3').lastElementChild.innerHTML = dataStuff.msg3;
	document.getElementById('line3').lastElementChild.style.fontSize = dataStuff.msg3FS+"px";

    document.getElementById('buy').lastElementChild.innerHTML = dataStuff.buy;
    document.getElementById('buy').lastElementChild.style.fontSize = dataStuff.buyFS+"px";

    document.getElementById('sell').lastElementChild.innerHTML = dataStuff.sell;
    document.getElementById('sell').lastElementChild.style.fontSize = dataStuff.sellFS+"px";

	document.getElementById('legal').lastElementChild.innerHTML = dataStuff.legal;
	document.getElementById('legal').lastElementChild.style.fontSize = dataStuff.legalFS+"px";
	
	document.getElementById('disclaimer').lastElementChild.innerHTML = dataStuff.disclaimer;
	document.getElementById('disclaimer').lastElementChild.style.fontSize = dataStuff.disclaimerFS+"px";

	function bgExitHandler(e) {
        Enabler.exitOverride('Background Exit', dynamicContent.JP_Volatility_Templates_Sheet1[0].CLICKTHROUGH.Url);
    }

    function sellExitHandler(e) {
        Enabler.exitOverride('Sell Exit', dynamicContent.JP_Volatility_Templates_Sheet1[0].CTA_CLICKTHROUGH.Url);
    }

    function buyExitHandler(e) {
        Enabler.exitOverride('Buy Exit', dynamicContent.JP_Volatility_Templates_Sheet1[0].CTA_CLICKTHROUGH.Url);
    }

    document.getElementById('bg-exit').addEventListener('click', bgExitHandler, false);
    document.getElementById('bg-exit').addEventListener('touchstart', bgExitHandler, false);

    document.getElementById('sell').addEventListener('click', sellExitHandler, false);
    document.getElementById('sell').addEventListener('touchstart', sellExitHandler, false);
    
    document.getElementById('buy').addEventListener('click', buyExitHandler, false);
    document.getElementById('buy').addEventListener('touchstart', buyExitHandler, false);
	
	loopLimit = dataStuff.loop;
    timing.f1sec = dataStuff.f1sec;
    timing.f2sec = dataStuff.f2sec;
    timing.f3sec = dataStuff.f3sec;
    timing.lsec = dataStuff.lsec;
    
    ctaAnimationStyle = parseInt(dataStuff.ctaAnimation);
	
    updatePosition();
	initBanner();
}
function initBanner(){
    
    tl = new TimelineLite({onUpdate:updateSlider, onComplete:handleLoop});
    
    function handleLoop(){
        if(loopLimit == 0){
            tl.restart();
        }else{
            currentLoop ++;
            if ( currentLoop <= loopLimit ){
                createAnimation();
            }else{
                tlComplete = true;
            }
        }
    }
    
    createAnimation();
    
    function createAnimation(){
        tl.clear();
        var legalElementText = document.getElementById('legal').lastElementChild.innerHTML;
        var hasLegal = (legalElementText != "");
        var finalLoop = (currentLoop >= loopLimit);
        if(loopLimit == 0) finalLoop = false;

        showFrame1();
        hideFrame1();
        showFrame2();
        
        if(!finalLoop && !hasLegal){
            hideFrame2();
        }
        if(hasLegal){
            hideFrame2();
            showLegal();
            hideLegal();
        }
        if(finalLoop && hasLegal){
            showFrame2();
        }
    }
    
    function showFrame1(){
        
        tl.set(market, {left: -728+marketLeft, opacity: 1 });
        tl.set(line1, {left: -728});
        tl.set(line2, {left: -728});
        tl.set(line3, {left: -728});
        tl.set(sell, {bottom: 90, opacity: 1 });
        tl.set(buy, {bottom: -90, opacity: 1 });
        tl.set(graph, {width: 0, opacity: 0.7 });

        var tweens = [];
        tweens.push(TweenMax.to(line1, 0.5, { left: 10}));
        tweens.push(TweenMax.to(line2, 0.5, { left: 10}));
        tweens.push(TweenMax.to(graph, 0.8, { width: 728}));
        tweens.push(TweenMax.to(market, 0.5, { opacity: 1, left: marketLeft } ));
        tweens.push(TweenMax.to(disclaimer, 0.2, { opacity: 1 } ));
        tl.add(tweens, "+=0", "start");

        tl.to(market, 0.2, { scale:1.2 });
        tl.to(market, 0.2, { scale:1 });

        tl.to(sell, 0.5, { bottom:10 });
        tl.to(buy, 0.5, { bottom:10 }, "-=0.5");
        tl.to(sell, 0.2, { scale:1.2 });
        tl.to(buy, 0.2, { scale:1.2 }, "-=.1");
        tl.to(sell, 0.2, { scale:1 });
        tl.to(buy, 0.2, { scale:1 }, "-=.1");
    }
    function hideFrame1(){
        var tweens = [];
        tweens.push(TweenMax.to(line1, 0.5, { left: -728} ));
        tweens.push(TweenMax.to(line2, 0.5, { left: -728} ));
        tl.add(tweens, "+="+timing.f1sec, "start");
    }
    function showFrame2(hasMessage3){
        tl.set(line3, {left: -728});
        tl.set(sell, {opacity: 1});
        tl.set(buy, {opacity: 1});
        tl.set(graph, {opacity: 0.7});
        tl.set(market, {opacity: 1});
        
        var marketX = 505 - document.getElementById("market").offsetWidth/2;
        
        var tweens = [];
        tweens.push(TweenMax.to(line3, 0.5, { left: 10}));
        tweens.push(TweenMax.to(market, 0.5, { left: marketX}));
        tweens.push(TweenMax.to(disclaimer, 0.2, { opacity: 1 } ));
        tl.add(tweens, "+=0", "start");
    }
    function hideFrame2(){
        var tweens = [];
        tweens.push(TweenMax.to(line3, 0.5, { left: -728}));
        tl.add(tweens, "+="+timing.f2sec, "start");
    }
    function showLegal(){
        var tweens = [];
        tweens.push(TweenMax.to(graph, 0.2, { opacity: 0 } ));
        tweens.push(TweenMax.to(disclaimer, 0.2, { opacity: 0 } ));
        tweens.push(TweenMax.to(sell, 0.2, { opacity: 0 } ));
        tweens.push(TweenMax.to(buy, 0.2, { opacity: 0 } ));
        tweens.push(TweenMax.to(market, 0.2, { opacity: 0 } ));
        tl.add(tweens, "+=0", "start");

        tl.to(legal, 0.2, { opacity:1 });
    }
    function hideLegal(){
        var tweens = [];
        tweens.push(TweenMax.to(legal, 0.1, { opacity: 0 } ));
        tl.add(tweens, "+="+timing.lsec, "start");
    }
}

function updatePosition(){
    var line1 = document.getElementById('line1');
	var line2 = document.getElementById('line2');
	var line3 = document.getElementById('line3');
	var disclaimer = document.getElementById('disclaimer');
    var legal = document.getElementById('legal');
    var market = document.getElementById('market');
	
	var mainWidth = document.getElementById("main").offsetWidth;
	var mainHeight = document.getElementById("main").offsetHeight;
	var logoHeight = document.getElementById("logo").offsetHeight;
    var legalHeight = legal.offsetHeight;
    var line1Height = line1.offsetHeight;
	var line2Height = line2.offsetHeight;
	var line3Height = line3.offsetHeight;
	var disclaimerHeight = disclaimer.offsetHeight;
    var marketHeight = document.getElementById('market').offsetHeight;
    
    var line2Y = line1.offsetTop + line1Height;
    line2.style.top =  line2Y + "px";

    var marketX = 15 + line1.offsetWidth;
    market.style.left =  marketX + "px";
    marketLeft = marketX;

    var discY = (mainHeight - disclaimerHeight - 5);
    disclaimer.style.top =  discY + "px";
}

function parseBannerCode(bannerCode){
	var dataObj={};
	var dataList = bannerCode.split("||");
	var param;
	for(var i=0; i < dataList.length; i++){
		param = String(dataList[i]).split("=");
		dataObj[param[0]] = unescape((String(param[1])));
	}
	return dataObj;
}

function setListeners(){
	// restart animation on rollover
	var bg_exit = document.getElementById('bg-exit');
	var sell_btn = document.getElementById('sell');
	
	bg_exit.onmouseover = function(e){
        console.log(tlComplete);
        if(tlComplete){tl.restart();tlComplete = false;}
		bannerRollover();
	};
	bg_exit.onmouseout = function(e){
		bannerRollout();
	};
	sell_btn.onmouseover = sellRollover;
	sell_btn.onmouseout = sellRollout;
}
function bannerRollover(){
	Enabler.counter("mainClickthrough OVER");
	Enabler.startTimer("mainClickthroughTimer");
}
function bannerRollout(){
	Enabler.counter("mainClickthrough OUT");
	Enabler.stopTimer("mainClickthroughTimer");
}
function sellRollover(){
	Enabler.counter("sell OVER");
	Enabler.startTimer("mainClickthroughTimer");
}
function sellRollout(){
	Enabler.counter("sell OUT");
	Enabler.stopTimer("mainClickthroughTimer");
}
function rollOverReplayTracking(){
	Enabler.counter("mainClickthrough OVER REPLAY");
}
/* 
***************************************************************************************************************************************************************************************************************************************
progress slider
**************************************************************************************************************************************************************************************************************************************** 
*/
var fb = document.getElementById('feedback');
var progressSlider = document.getElementById('progressSlider');
var progressBtn = document.getElementById('progressBtn');
var playPauseBtn =  document.getElementById('playControl'); 
playPauseBtn.addEventListener('click', playPause, false);
progressSlider.addEventListener('mousedown', sliderStart, false);
progressSlider.addEventListener('touchstart', sliderStart, false);
window.addEventListener('mouseup', sliderEnd, false);
window.addEventListener('touchend', sliderEnd, false);
var isPlaying = true;

//width
var progressSliderWidth = progressSlider.clientWidth;
var progressBtnWidth = progressBtn.offsetWidth;
//position
var progressSliderX = progressSlider.getBoundingClientRect().left;
function playPause()
	{
		if (isPlaying)
		{
			isPlaying = false;
			tl.pause();
			playPauseBtn.innerHTML = 'PLAY';
		}
		else 
		{
			isPlaying = true;
			tl.play();
			playPauseBtn.innerHTML = 'PAUSE';
		}
	}
function updateSlider() 
{
    tlProgress = tl.progress() *  ( progressSliderWidth - progressBtnWidth );
    progressBtn.style.marginLeft =  tlProgress.toString() + "px";
    //time
    fb.innerHTML = Math.round( tl.totalTime() * 100 )/100;
    try{
        var event = new Event('tl-update');
        window.dispatchEvent(event);
    }catch(e){
        //Event not supported
    }
} 

function sliderStart(e)
{
    tl.pause();
    progressSlider.addEventListener('mousemove', sliderMove, false);
    progressSlider.addEventListener('touchmove', sliderMove, false);
}
function sliderEnd(e)
{
    if (isPlaying) tl.play();
    progressSlider.removeEventListener('mousemove', sliderMove, false);
    progressSlider.removeEventListener('touchmove', sliderMove, false);
}

function sliderMove(e)
{
    clientX = e.clientX || e.touches[0].clientX;
    clientX -= progressSliderX;
    //fb.innerHTML = clientX;
    mousePos = clientX - (progressBtnWidth/2);
    if ( mousePos >= 0 && mousePos <= (progressSliderWidth - progressBtnWidth) )
    {
        progressBtn.style.marginLeft =  mousePos.toString() + "px";
        perc = mousePos / (progressSliderWidth - progressBtnWidth);
        tl.progress(perc).pause();
    }
}
/* **************************************************************************   /   *********************************************************************************** */