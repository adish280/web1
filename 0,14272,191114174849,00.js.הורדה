//Matrix variables
var matrixVideoId; 
var matrixChannelId;
 
YnetLBP = { 
	getLightbox : function(params) {
		if (!this._instance) {
			this._instance = new YnetLightboxPlayer(params);
		}
		
		return this._instance;
	},
	
	onResize : function(videoHeight, overflow) {
		if (overflow != this.previousOverflow) {
			this.isPlayerResized = true;
			this.previousOverflow = overflow;
		}
		
		
		this.isPlayerSetToFullSize = overflow == 0;
		yq('#ynet_lightbox_video_container_wrap').height(videoHeight - overflow);
	},
	
	playByVideoId : function(videoId, params) {
		this.getLightbox(params).play(videoId);
 	},
	
	cache : {
		videosPool : {},
		relatedVideosPool : {},
		addVideo : function(videoId, videoData){
			this.videosPool[videoId] = videoData;
		},
		getVideo : function(videoId, callback){
			var self = this;
			
			if (!this.videosPool[videoId]) {
				YnetLBP.ajax.getVideoData(videoId, function(videoObject){
					self.addVideo(videoId, videoObject);
					callback(videoObject);
				});
			} else {
				callback(this.videosPool[videoId]);
			}
		},
		addRelatedVideos : function(channelId, videoData){
			this.relatedVideosPool[channelId] = videoData;
		},
		getRelatedVideos : function(channelId, callback){
			var self = this;
			
			if (!this.relatedVideosPool[channelId]) {
				YnetLBP.ajax.getRelatedVideos(channelId, function(videoArray){
					self.addRelatedVideos(channelId, videoArray);
					callback(videoArray);
				});
			} else {
				callback(this.relatedVideosPool[channelId]);
			}
		}
	},
	
	ajax : {
		getVideoData : function(videoId, callback) {
			var url = '/ext/Common/App/Video/CmmGetVideoInfo/0,14274,videoId,00.html';
			url = url.replace('videoId', videoId);
			
			yq.get(url, function(res){
				res = res.replace(/<!--.*-->/g, '');
				
				try {
					var videoObject = eval('(' + res + ')');
				} catch(e) {
					var videoObject = null;
				}
				
				callback(videoObject);
			});
		},
		getRelatedVideos : function(channelId, callback){
			var url = '/ext/Common/App/Video/CmmGetCategoryVideos/0,14273,ChannelId,00.html';
			url = url.replace('ChannelId', channelId);
			
			yq.get(url, function(res){
				res = res.replace(/<!--.*-->/g, '');
				
				try {
					var videoArray = eval('(' + res + ')');
				} catch(e) {
					var videoArray = new Array;
				}
				
				callback(videoArray);
			});
		}
	}
}

//*************** Constructor *****************//

window.YnetLightboxPlayer = function(params) {
	var self = this;
	var isMotorollaDesign = params.isMotorollaDesign || false;
	var fbShareUrl = params.fbShareUrl || 'https://www.facebook.com/sharer.php?u=VIDEO_LINK';
	var motorolaHeaderImageHeight = params.motorolaHeaderImageHeight || 0;
	var playerType = params.playerType || '';
	var isSamsungDesign = !!params.isSamsungDesign;
	
	this.cache = YnetLBP.cache;
	this.videos = [];
	this.config = {
		videoContainerId : 'ynet_lightbox_video_container',
		ExternalvideoContainerId : 'ynet_lightbox_external_video_container',
		sharingContainerId : 'ynet_lightbox_sharing',
		fbShareUrl : fbShareUrl,
		isMotorolaDesign : isMotorollaDesign,
		motorolaHeaderImageHeight : motorolaHeaderImageHeight,
		numOfLightboxItems : 7,
		thumbnailEnlargedWidth : 120,
		thumbnailEnlargedHeight : 90,
		thumbnailWidth	: 87,
		thumbnailHeight : 65,
		playerType : playerType,
		onLightboxOpen : params.onLightboxOpen,
		playerDimensions : {
			width : 640,
			height : 386
		},
		isSamsungDesign : isSamsungDesign
	}
	this.lightBox =  new YnetLightbox(function(overflow){YnetLBP.onResize(self.config.playerDimensions.height, overflow)});
	this.html.container = this.lightBox.getContainer();
};



YnetLightboxPlayer.prototype = {
	_getPlayerDimensions : function(playerType){
		var dimensions = this.CONST.PlayerDimensions[playerType];
		
		dimensions.height += this.CONST.FlowplayerControlBarHeight;
		
		return dimensions;
	},
	_getTotalVideosNumber : function(){
		return this.videos.length;
	},
	_getVideoByIndex : function(index){
		if(index >= 0 && index < this.videos.length) {			
			var videoData = this.videos[index];
			videoData.index = index;
			
			return videoData;
		}
		return null;
	},
	play : function(videoId,overWriteParams,footerVideos){
		matrixVideoId = videoId;
		
		var self = this;
		var foundDuplicate = false;
		if (videoId == 0) {
			self._play(0,overWriteParams);
		} else {
			if (typeof(footerVideos)!='undefined') {
				videoId = videoId - 1;
				self.videos = footerVideos;
				self._play(videoId,'',footerVideos);
			} else {
				this.cache.getVideo(videoId, function(videoData){
					if (videoData) {
						self.cache.getRelatedVideos(videoData.subChannelId, function(relatedVideos){
							self.videos = new Array(videoData).concat(yq.grep(relatedVideos.videos, function(item, index){
								if (item.videoId == videoId) {
									foundDuplicate = true;
									return false;
								} else if (!foundDuplicate && index == 6) {
									return false;
								} else {
									return true;
								}
							}));
							self._play(0);
							
						});
					}
				});
			}
		}
	},
	_play : function(videoIndex,overWriteParams,footerVideos){
		var self = this;
		var videoData = overWriteParams || this._getVideoByIndex(videoIndex);
		if(videoData){
			if (videoData.linkType=='external_url') {	
				var container = yq('#ynet_lightbox_video_container [id^=yntfpcontainer]');
			
				// get the player from the lightBox
				if (container && container.length) {
					var fp = flowplayer(container.get(0));
					if (fp) {
						if(this.lightBox.visible()){
							self.closeLightbox();
							window.open(videoData.contentLink,'Ynet');
						}
					}
				}
			} else {
				if(!this._staticHtmlInitialized){
					this.lightBox.html(this.html.getStaticPlayer(this.config));
					this.initStaticHtmlEvents();
					this._staticHtmlInitialized = true;
				};
				if(!this.lightBox.visible()){
					if (typeof(footerVideos) == 'undefined') {
						window.has_footer_videos = 0;
						this.html.initDynamicPlayer(this.config, this.videos);
					} else {
						window.has_footer_videos = 1;
						this.html.initDynamicPlayer(this.config, footerVideos);
					}
					
					var footer = this.html.getContainer().find('#ynet_lightbox_video_footer');
					if (videoData.customDesignParams && videoData.customDesignParams.showFooter === false) {
						footer.hide();
					} else {
						footer.show();
					};
					
					this.lightBox.show({onLightboxOpen:function(){
							if (typeof self.config.onLightboxOpen == 'function') {
								self.config.onLightboxOpen(videoData);
							};
							self.loadVideo(videoData);
						}
					,customOverlayClass: videoData.customDesignParams ? videoData.customDesignParams.lightboxOverlayClass : ''
					,customContentClass: videoData.customDesignParams ? videoData.customDesignParams.lightboxContentClass : ''
					,topHtml: videoData.customDesignParams ? videoData.customDesignParams.topHtml : ''
					,offsetY: videoData.customDesignParams ? videoData.customDesignParams.offsetY : ''});
				} else {
					this.loadVideo(videoData);
				};
				this.html.updatePlayerContent(this.config, videoData);
			}
		}
	},
	loadExternalUrl : function(videoData){
		
		var res = [];
		var self = this;
		var url = videoData.externalBroadcastIframe;
		
		res.push('<iframe id="ynet_lightbox_iframe" src="' + url + '" scrolling=yes frameborder=0 marginheight=0 marginwidth=0 vspace=0 hspace=0 allowtransparency="true"></iframe>');

		var obj=this.externalPlayerOn();
		obj.html(res.join(''));
	},
	loadVideo : function(videoData){
		if(videoData.type == 3) {
			this.loadExternalUrl(videoData);
		} else {
			if(videoData){
				var dimensions = this.getVideoDimensions();
				this.loadPlayer(videoData, dimensions);
			}
		}
		
	},
	
	loadPlayer : function(videoData,dimensions){
		if (typeof playerType === 'undefined') {
			playerType = 4;
		}
		var _this = this;
		var nextItemId = (videoData.index + 1) % this._getTotalVideosNumber();		
		var nextVideoData = this._getVideoByIndex(nextItemId);
		
		var params = {
			destId:  this.config.videoContainerId,
			onFinish: function(){
				_this._play(nextItemId);	
			},
			resizePlayerContainer: YnetLBP.isPlayerResized,
			setPlayerToFullSize: YnetLBP.isPlayerSetToFullSize,
			player_type: playerType
		};
		this.playerOn();
		if (CmmAppVideoApi.unloadPlayer) {
			CmmAppVideoApi.unloadPlayer(this.videoContainerId);
		};
		
		var is_lightbox = true;
	
		if(typeof playerType !== 'undefined' && (playerType == 2 || playerType == 3)) {
			CmmAppMatrixVideoApi.loadMatrixPlayer('LightBoxArticlePlayer', videoData.videoId, dimensions.width + 1, dimensions.height + 1, params);
		} else {
			CmmAppVideoApi.loadPlayer(this.config.playerType, videoData.videoId, dimensions.width + 1, dimensions.height + 1, params, is_lightbox);
		}
			YnetLBP.isPlayerResized = false;
	},
	
	playerOn : function () {
		var _this = this;
		this.html.getContainer().find('#' + this.config.ExternalvideoContainerId).hide();
		this.html.getContainer().find('#' + this.config.videoContainerId).show();
	},
	externalPlayerOn : function (html) {
		var _this = this;
		this.html.getContainer().find('#' + this.config.videoContainerId).hide({duration:0,queue:false});
		
		return this.html.getContainer().find('#' + this.config.ExternalvideoContainerId).show({duration:0,queue:false});
	},
	getVideoDimensions : function(){	
		var v = this.html.getContainer().find('#ynet_lightbox_video_container_wrap');
		return {width: v.width(), height: v.height()};
	},
	closeLightbox : function(){
		this.lightBox.hide();
		if (CmmAppVideoApi.unloadPlayer) {
			CmmAppVideoApi.unloadPlayer(this.config.videoContainerId);
		}
	},
	initStaticHtmlEvents : function(){
		var self = this;
		this.html.getContainer().find('#ynet_lightbox_video_header .ynet_lightbox_video_close').click(function(){
			self.closeLightbox();
		});
		
		yq('#ynet_lightbox_overlay').click(function(){
			self.closeLightbox();
		});
		
		this.html.getContainer().find('#ynet_lightbox_video_footer').click(function(event){
			var target = yq(event.originalTarget || event.srcElement);
			var thumbnail = target.parents('.ynet_lightbox_thumbnail');
			if (thumbnail.length) {
				self._play(parseInt(thumbnail.attr("rel")));
			}
		});
	},
	
	html : {
		getStaticPlayer : function(config) {
			return this._getBasicStructure(config);
		},
		initDynamicPlayer : function(config, videos){
			this._initFooter(config, videos);
		},
		getContainer : function() {
			return this.container;
		},
		updatePlayerContent :function(config, videoData){
			// Update title			
			var title = this.container.find('.ynet_lightbox_video_header_title');
			var fullArticle = this.container.find('.ynet_lightbox_full_article');
			var titleTxt = videoData.title + ' ' + videoData.subTitle;
			try{var creditTxt = ( videoData.video.credits && videoData.flp6Ifrmtype ) ? videoData.video.credits : ""}catch(e){}
			var link = '<a href="' + this.escape(videoData.contentLink) + '" target="_blank"></a>';
			if (videoData.hasArticle) {
				title.html(link).find('a').html(titleTxt);
				fullArticle.html(link).show().find('a').html('לכתבה המלאה');
			} else {
				title.html(titleTxt);
				fullArticle.hide();
			};
			// Dim all the thumbnails
			this.container.find('.ynet_lightbox_thumbnail_shade').addClass('ynet_lightbox_thumbnail_shade_on').show();
			// Highlight the selected video thumbnail
			
			this.container.find('.ynet_lightbox_thumbnail[rel="'+videoData.index+'"] .ynet_lightbox_thumbnail_shade')
				.removeClass('ynet_lightbox_thumbnail_shade_on');
			// Update Facebook share URL
			this.container.find('.ynet_lightbox_sharing_fb').attr('href', config.fbShareUrl.replace('VIDEO_LINK', encodeURI(this.escape(videoData.contentLink))));
		},
		// Init the html that doesn't change between player instances
		_getBasicStructure : function(config){
			var res = [];
			res.push('<div id="ynet_lightbox_lightbox" ' + (config.isMotorolaDesign ? 'class="ynet_lightbox_lightbox_motorolla"' : '') + (config.isSamsungDesign ? 'class="ynet_lightbox_lightbox_samsung"' : '') + '>');
				if (config.isMotorolaDesign) {
					res.push('<img src="/images/hp_player_lightbox_top.png" height="' + config.motorolaHeaderImageHeight + '" />');
				}
				
				res.push('<div id="ynet_lightbox_video_header">')
					res.push(this._getHeader());
				res.push('</div>');
				res.push('<div id="ynet_lightbox_video_container_wrap">');
					res.push('<div id="' + config.videoContainerId + '" style="height:' + config.playerDimensions.height + 'px;"><div class="' + config.videoContainerId + '"></div></div>');
					res.push('<div id="' + config.ExternalvideoContainerId + '" ></div>');
				res.push('</div>');
				res.push('<div id="ynet_lightbox_video_footer">');
					res.push('<div id="ynet_lightbox_video_footer_inner"></div>');					
				res.push('</div>');
			res.push('</div>');
			
			return res.join('');
		},
		_getHeader : function(){
			var self = this;
			var res = [];
			
			res.push('<div class="ynet_lightbox_video_header_p">');
				res.push('<div class="ynet_lightbox_floatr ynet_lightbox_video_header_title_wrap">');
					res.push('<span class="ynet_lightbox_video_header_title"></span>');
					res.push('&nbsp;<span class="ynet_lightbox_full_article"></span>');
				res.push('</div>');
				res.push('<div class="ynet_lightbox_floatl ynet_lightbox_video_close ynet_lightbox_pointer">');
					res.push('<img class="ynet_lightbox_floatl" src="/images/hp_player_close.gif" />');
					res.push('<span class="closetextspan"> סגור</span>');
				res.push('</div>');
			res.push('</div>');
			
			return res.join('');
		},
		_initFooter : function(config, videos){
			var self = this;
			var res = [];
			res.push('<div id="ynet_lightbox_thumbnails">');
				for(var i = 0; i < config.numOfLightboxItems && i < videos.length; i++){			
					var video = videos[i];
					
					var title = video.title;
					if(title.length > 19) {
						title = title.substr(0,18) + '...';
					} 
					
					res.push('<div class="ynet_lightbox_pointer ynet_lightbox_floatl_ ynet_lightbox_thumbnail" rel="'+i+'">');
						res.push('<div class="ynet_lightbox_thumbnail_img">');
							if (typeof(video.video) == 'object' && this.escape(video.video.imgPath) != '' && this.escape(video.imgPath) == '')
							{
								var imagePath = this.escape(video.video.imgPath);
							} else {
								var imagePath = this.escape(video.imgPath);
							}
							if (imagePath == '') {
								imagePath = '/images/external_player_thumbnail.png';
							}
							res.push('<img src="' + imagePath + '" />');
							res.push('<div class="ynet_lightbox_thumbnail_overlay">' + this.escape(title) + '</div>');
							res.push('<div class="ynet_lightbox_thumbnail_shade"></div>');
						res.push('</div>');
					res.push('</div>');
					if(i < config.numOfLightboxItems - 1) {
						var last = (i == 0) ? 'ynet_lightbox_thumbnail_separator_first' : '';
						res.push('<div class="ynet_lightbox_thumbnail_separator '+last+'"></div>');
					};
				};
			res.push('</div>');
			res.push('<div id="' + config.sharingContainerId + '">');
				res.push('<a href="" target="_blank" class="ynet_lightbox_sharing_fb" ></a>');
			res.push('</div>');
			
			this.container.find('#ynet_lightbox_video_footer_inner').html(res.join(''));
			
			this.container.find('.ynet_lightbox_thumbnail').hover(
				function(){self.enlargeThumbnail(config, this);},
				function(){self.resetThumbnail(config, this);}
			);
			
		},
		enlargeThumbnail : function(config, thumbnail){
			thumbnail = yq(thumbnail);
			var img = thumbnail.find('.ynet_lightbox_thumbnail_img');
			var overlay = img.find('.ynet_lightbox_thumbnail_overlay');
			var shade = thumbnail.find('.ynet_lightbox_thumbnail_shade_on');
			
			var animate = 'css';
			var fadeIn = 'show';
			var fadeOut = 'hide';
			var duration = undefined;
			
			// Give a higher z-index to current thumbnail
			thumbnail.css('z-index', 10);
			
			// Undim the thumbnail
			shade.hide();
			
			// Show the text overlay
			overlay.stop(true)[animate]({
				top: -20
			}, duration);
			
			// Draw border
			img.addClass('ynet_lightbox_thumbnail_enlarged');
			
			// Enlarge the thumbnail
			img[animate]({
				width: config.thumbnailEnlargedWidth,
				height: config.thumbnailEnlargedHeight,
				top: -((config.thumbnailEnlargedHeight - config.thumbnailHeight) / 2),
				right: -((config.thumbnailEnlargedWidth - config.thumbnailWidth) / 2)
			}, 150);
		},
		resetThumbnail : function(config, thumbnail){
			thumbnail = yq(thumbnail);
			var img = yq(thumbnail).find('.ynet_lightbox_thumbnail_img');
			var overlay = img.find('.ynet_lightbox_thumbnail_overlay');
			var shade = thumbnail.find('.ynet_lightbox_thumbnail_shade_on');
			
			var animate = 'css';
			var fadeIn = 'show';
			var fadeOut = 'hide';
			var duration = undefined;
			
			// Hide the text overlay
			overlay.stop(true)[animate]({
				top: 0
			}, duration);
			
			// Shrink the thumbnail
			img.css({
				width: config.thumbnailWidth,
				height: config.thumbnailHeight,
				top: 0,
				right: 0
			});
			
			// Dim the thumbnail
			shade.css('filter', 'alpha(opacity=70)')[fadeIn]();
			
			// Remove border
			img.removeClass('ynet_lightbox_thumbnail_enlarged');
			
			// Reset z-index
			thumbnail.css('z-index', 1);
		},
		escape : function(str){
			if(str){
				return str.replace(new RegExp('&','g'),'&amp;').replace(new RegExp('<','g'),'&lt;').replace(new RegExp('>','g'),'&gt;').replace(new RegExp("'",'g'),'&#39;').replace(new RegExp('"','g'),'&quot;');
			}
			return '';
		}
	}
}


window.YnetLightboxPlayer.html = function() {
	
}

//*************** YnetLightbox object *****************//
window.YnetLightbox = function(resize) {
	this.resize = resize;
	this.page = {};
	this.init();
};
YnetLightbox.prototype = {
	init : function() {
		
		this.page.wl = window.location.href.split('/');		
		this.page.allparams = this.page.wl[this.page.wl.length-1].split(',');			
		this.page.idparams=this.page.allparams[2].split('L-');		
		this.page.pageid = this.page.idparams[1];
		
		matrixChannelId = this.page.pageid;
		
		this.overlay = yq('<div id="ynet_lightbox_overlay"></div>');
		this.content = yq('<div id="ynet_lightbox_content"></div>');
		yq('body').append(this.overlay);
		yq('body').append(this.content);
		
		var _this = this;
		yq(window).resize(
			function(){_this.updatePosition();}
		)
	},
	show : function(params) {
		var self = this;
		var params = params || {};
		if (typeof(window.pageRefreshDisable)=='function'){
			window.pageRefreshDisable();
		};

		this.content.addClass(params.customContentClass);
		this.overlay.addClass(params.customOverlayClass);
		
		// hide all iframes to prevent flash objects from showing through

		if (this.page.pageid != 8){
			yq('iframe').css('visibility', 'hidden');
		};
		
		//ie error
		// External resize function makes the necessary adjustements so the lightbox fits the screen
		if(typeof this.resize == 'function'){this.resize(this.getOverflow())};
		
		// Update lightbox position according to lightbox and window size
		this.updatePosition();
		
		// Show the lightbox
		this.overlay.css('filter', 'alpha(opacity=70)').fadeIn(function(){
			setTimeout(function(){
				self.content.fadeIn('slow',function(){
					if(typeof params.onLightboxOpen == 'function'){params.onLightboxOpen();};
				});
			}, 200);
		});
		
		return this;
	},
	hide : function(callback) {
		if (typeof(window.pageRefreshEnable)=='function'){
			window.pageRefreshEnable();
		};
		
		this.content.hide().removeClass();
		this.overlay.fadeOut('slow').removeClass();
		
		// bring iframes back
		if (this.page.pageid != 3263){
			yq('iframe').css('visibility', 'visible');
		}
		
		if(typeof callback == 'function'){callback();};
		
		return this;
	},
	html : function(html) {
		this.content.html(html);
		this.fullHeight = this.content.height();
		return this;
	},
	getContainer : function (){
		return this.content;
	},
	visible : function() {
		return this.content.is(':visible');
	},
	updatePosition : function() {
		var position = this.getPosition();
		this.content.css({
			'left': position.left + 'px',
			'top': position.top + 'px'
		});

	},
	getPosition : function() {
		var w = yq(window);
		var left = (w.width() / 2) - (this.content.width() / 2);
		var top = (w.height() / 2) - (this.content.height() / 2);
		
		return {
			left: left,
			top: top > 0 ? top : 0
		};
	},
	getOverflow : function(videoData){
		var heightOverflow = this.fullHeight - yq(window).height();
		return heightOverflow > 0? heightOverflow : 0;
	}
}

//Matrix functions
function matrixPlayerEvents (eventName, clipId, time){
    CmmAppMatrixVideoApi._matrixPlayerEvents(eventName, clipId, time);
};

function updateMatrixPlayerVariables (var_name){
	return CmmAppMatrixVideoApi._matrixPlayerGetParamValue(var_name, matrixVideoId, matrixChannelId,matrixChannelId);
};

