async function SendData(data, cb) {
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
      if (xhr.readyState == XMLHttpRequest.DONE) {
          if (cb) {
              cb(xhr.responseText)
          }
      }
  }
  xhr.open("POST", `https://${GetParentResourceName()}/nuicb`, true)
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send(JSON.stringify(data))
}
let getEl = function(id) { return document.getElementById(id) }
function setcontrol(type,index) {
  // console.log(type,index)
  return SendData({msg: 'carcontrol', type: type, index: index})
} 


let player;
let playerRuning = false;
let progressInterval = null;
let pausedVideoDuration = null;

function onYouTubeIframeAPIReady() {
  player = new YT.Player("player", {
    height: "1",
    width: "1",
    videoId: "",
    playerVars: {
      playsinline: 1,
    },
    events: {
      onReady: (e) => e.target.playVideo(),
      onStateChange: (e) => {
        if (e.data == YT.PlayerState.PLAYING) {
          playerRuning = true;
          $(".play-button").attr("src", "images/stop.svg");
          progressInterval = setInterval(() => {
            const duration = player?.getDuration() || 0;
            const currentTime = player?.getCurrentTime() || 0;
            const percentage = (currentTime / duration) * 100;
            $(".timeline").css("width", `${percentage}%`);
          }, 1000);
        } else if (e.data == YT.PlayerState.PAUSED) {
          playerRuning = false;
          clearInterval(progressInterval);
        } else if (e.data == YT.PlayerState.CUED) {
          e.target.playVideo();
        } else if (e.data == YT.PlayerState.ENDED) {
          playerRuning = false;
          updateVideoPreview("Nothing to play", "", "");
          clearInterval(progressInterval);
          $(".timeline").css("width", `0%`);
        }
      },
      onError: (e) => {
        playerRuning = false;
        $(".play-button").attr("src", "images/play.svg");
        updateVideoPreview("Nothing to play", "", "");
        clearInterval(progressInterval);
        $(".timeline").css("width", `0%`);
      },
    },
  });
}

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

window.addEventListener("message", ({ data }) => {
  if (!data) return;
  switch (data?.action) {
    case "show":
      $(".main-wrapper").show(0);
      $(".surukle").show(0);
      // $(".mini-surukle").hide(0);
      // $(".mini-menu").hide(0);
      break;

    case "hide":
        $(".main-wrapper").hide(0);
        $(".mini-menu").hide(0);
      break;

    case "playMusic":
      const currentDate = new Date().getTime() / 1000;
      const seekTo = currentDate - data.startedAt;

      if (seekTo >= (player.getDuration() || pausedVideoDuration)) {
        $.post(
          `https://${GetParentResourceName()}/controlMusic`,
          JSON.stringify({ action: "endMusic" })
        );
        return;
      }

      playMusic(data.musicLink, seekTo.toFixed(), data.playerState);
      break;

    case "stopMusic":
      if (player) {
        (async () => {
          for (let i = player.getVolume(); i > 0; i--) {
            player.setVolume(i);
            await wait(10);
          }
          player.seekTo(player.getDuration());
        })();
      }
      break;

    case "pauseMusic":
      pauseVideo();
      break;

    case "resumeMusic":
      resumeVideo();
      break;

    case "endMusic":
      playerRuning = false;
      $(".play-button").attr("src", "images/play.svg");
      updateVideoPreview("Nothing to play", "", "");
      clearInterval(progressInterval);
      $(".timeline").css("width", `0%`);
      break;
  }

  if (data?.vehicle) {

    $(".plaka").text(data?.vehicle.plaka);
    $(".fuel").text(`${(data?.vehicle.fuel || 100)?.toFixed(0)}%`);
    $('.fuel-bar').css({ 'stroke-dasharray': `${(data?.vehicle.fuel || 100)?.toFixed(0) * 2}% 400` })
    $(".temperature").text(
      `${data?.vehicle.engineTemperature?.toFixed(0) || 85}°`
    );
    $(".interior-temperature").text( "INTERIOR: " +
      `${data?.vehicle.engineTemperature?.toFixed(0) || 85}°`
    );
    
    $("#car-name").text(data?.vehicle?.name || "");
    $(".kilometer").text( "KILOMETER: " +
      parseFloat(data?.vehicle?.mileage || 0)?.toFixed(1) || "0"
    );
    $(".chart-km").text( 
      parseFloat(data?.vehicle?.mileage || 0)?.toFixed(1) || "0"
    );
  }
});

window.addEventListener("keydown", ({ key }) => {
  if (key == "Escape") $.post(`https://${GetParentResourceName()}/exitMenu`);
});

const updateMenuContainer = function () {
  const menuId = $(this).data("id");
  const noPage = $(this).data("nopage");

  if (noPage)
    return $.post(
      `https://${GetParentResourceName()}/${$(this).data("action")}`
    );

  $(".menu-categories")
    .children()
    .each((i, el) => {
      const className = $(el).attr("class").split(" ")[1];

      if (className == `menu-${menuId}`) {
        $(el).removeClass("menu-hidden");
      } else {
        $(el).addClass("menu-hidden");
      }
    });
};

const pauseVideo = () => {
  pausedVideoDuration = player.getDuration();
  player.pauseVideo();
  playerRuning = false;
  $(".play-button").attr("src", "images/play.svg");
};

const resumeVideo = () => {
  pausedVideoDuration = null;
  player.playVideo();
  playerRuning = true;
  $(".play-button").attr("src", "images/stop.svg");
};

const togglePlayVideo = (forcePlay) => {
  if (playerRuning) {
    pauseVideo();
  } else {
    resumeVideo();
  }
};

const getVideoId = (url) => {
  var regExp =
    /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*/;
  var match = url.match(regExp);
  return match && match[7].length == 11 ? match[7] : false;
};

const getVideoData = async (url) => {
  const data = await fetch(`https://youtube.com/oembed?url=${url}&format=json`)
    .then((res) => (res.ok ? res.json() : null))
    .catch((err) => null);

  if (!data) return null;

  return data;
};

const updateVideoPreview = (title, description, background) => {
  $(".song-name").text(title);
  $(".song-author").text(description);
 $(".cover-image").attr("src", background);
};

const playMusic = async (link, seekTo, playerState) => {
  const musicId = getVideoId(link);

  player?.setVolume($(".volume").val());

  player?.loadVideoById(musicId, seekTo);

  if (playerState == "paused") {
    player.pauseVideo();
    $(".play-button").attr("src", "images/play.svg");
    const percentage = (seekTo / pausedVideoDuration.toFixed()) * 100;
    $(".timeline").css("width", `${percentage}%`);
  } else {
    $(".play-button").attr("src", "images/stop.svg");
  }

  const videoData = await getVideoData(link);

  if (videoData)
    updateVideoPreview(
      videoData.title,
      videoData.author_name,
      videoData.thumbnail_url
    );

  $(".spotify-input").val("");
};

const musicInputChange = async () => {
  const link = $(".spotify-input").val();
  const musicId = getVideoId(link);

  if (!musicId) return;

  $.post(
    `https://${GetParentResourceName()}/controlMusic`,
    JSON.stringify({ action: "playMusic", musicLink: link })
  );
};

const actionButtonClick = (e) => {
  const action = $(e.currentTarget).data("action");
  $.post(`https://${GetParentResourceName()}/${action}`);
};

const doorActionButtionClick = (e) => {
  const doorIndex = $(e.currentTarget).data("index");
  // $(e.currentTarget).attr("src", "images/acik.svg");
  $.post(
    `https://${GetParentResourceName()}/toggleDoor`,
    JSON.stringify(doorIndex)
  );
};

const musicVolumeChange = () => {
  if (player) player?.setVolume($(".volume").val());
};

$(document).ready(() => {
  $(".menu-exit").on("click", () =>
    $.post(`https://${GetParentResourceName()}/exitMenu`)
  );
  $(".sidebar-option").on("click", updateMenuContainer);
  $(".play-button").on("click", () => {
    if (playerRuning) {
      pauseVideo();
    } else {
      resumeVideo();
    }

    $.post(
      `https://${GetParentResourceName()}/controlMusic`,
      JSON.stringify({
        action: !playerRuning ? "pauseMusic" : "resumeMusic",
      })
    );
  });
  $(".spotify-input").on("input", musicInputChange);
  $(".lights-button").on("click", actionButtonClick);
  $(".kapilar").on("click", doorActionButtionClick);
  $(".mdoor-button").on("click", doorActionButtionClick);
  $(".volume").on("change", musicVolumeChange);
});
function SetNeonStyle(val) {
  SendData({ msg: 'neonstyle', val: val })
}

window.addEventListener("message", function(event) {
  var vehicle = event.data;
  switch (vehicle.carhud) {
      case 'arabada':
          var gear = vehicle.gear
          var speedsInt = vehicle.speed.toFixed()
          var mesafe = vehicle.metre.toFixed()
          var motor = vehicle.motor
          var head = vehicle.heading.toFixed()
          $(".distance").text(mesafe + "m");
          $(".distance-description").text(mesafe + " meters to destination");
          $(".ok").css("rotate", `${head}deg`);
          $('.speed-bar').css("stroke-dasharray", `${speedsInt}% 1500`)
          $(".speed").text(speedsInt);
          $('.rpm-bar').css( "stroke-dasharray", `${gear * 150}% 400` )
            if (vehicle.gear == 0 && vehicle.rpm > 1) {
              $('.rpm').text(`R`)
          } else if (vehicle.gear == 0) {
              $('.rpm').text(`P`)
          } else if (vehicle.gear > 0) {
              $('.rpm').text(vehicle.gear)
          }
          if (motor < 1000.0 && 500.0 < motor) {
            $(".status-svg").attr("src", "images/safe.svg");
            $('.status').text(`Status : Safe`)
        } else if (motor < 500.0 && 250.0 < motor) {
            $(".status-svg").attr("src", "images/warn.svg");
            $('.status').text(`Status : Warning`)
        } else if (motor < 250.0) {
            $(".status-svg").attr("src", "images/emergency.svg");
            $('.status').text(`Status : Emergency`)
        }
          break
      case 'indi':
//sd
          break
  }
});




$("#open-mini").click(function(e) {
    $(".surukle").hide(0);
    $(".mini-surukle").hide(0);
    $(".mini-menu").hide(0);
    $(".main-wrapper").hide(0);
});
$(".fa-expand").click(function (e) { 
  $(".surukle").show(0);
  $(".mini-surukle").hide(0);
  $(".mini-menu").hide(0);
  $(".main-wrapper").show(0);
});

$(".fawindowminimize").click(function (e) { 
  $(".surukle").hide(0);
  $(".mini-surukle").show(0);
  $(".mini-menu").show(0);
  $(".main-wrapper").hide(0);
});


$(".faxmark").click(function (e) { 
  $(".surukle").hide(0);
  $(".mini-surukle").hide(0);
  $(".mini-menu").hide(0);
  $(".main-wrapper").hide(0);
  $.post(
    `https://${GetParentResourceName()}/closeui`,
    JSON.stringify({}));
});

window.addEventListener('message', (event) => {
  let item = event.data;
  if (item.type === 'open2') {
      $('.location-1').text(`${item.streetName}`);
      $('.location-2').text(`${item.streetName2}`);
  }
})
  $( function() {
  $(".mini-surukle").draggable();
  } );
  $( function() {
  $(".surukle").draggable();
  } );