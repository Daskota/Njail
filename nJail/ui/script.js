$(function() {
    $('body').fadeIn();
    $('#jail-container').hide();
    $('#jail-hud').hide();
    $('#jail-pannel').hide();
    window.addEventListener('message', function(event) {
        var data = event.data;
  
        if (data.action == "openJailMenu") {
            $('#jail-pannel').hide();
            $('#jail-hud').hide();
            $('body').fadeIn(500);
            $('#jail-container').fadeIn(500);
        }
        if (data.action == "JailInfo") {
            $('#jail-container').hide(0);
            $('#jail-hud').fadeIn(500);
            $('.jailtime').html(event.data.time);
            $('.value-jail').css('height', event.data.pourcentage + '%');
        }
        if (data.action == "UnJail") {
            $('#jail-pannel').hide();
            $('#jail-container').hide(0);
            $('#jail-hud').fadeOut(250);
        }
        if (data.action == "openJailPannel") {
            $('#jail-hud').hide();
            $('#jail-container').hide();
            $('#jail-reason').hide();
            $('#close-reason').hide();
            $('#jail-pannel').fadeIn(500);
            $('.player-injail').html(event.data.nbJail);
            $('.playerrank').html(event.data.rank);
            addPlayerInList(event.data.playerInJailList);
        }
    });
})


function addPlayerInList(array) {
    var elem = document.getElementById("player-list");
    
        for (let i = 0; i < array.length; i++) {
            elem.innerHTML += `
            <div class="player-list">
                <img src="img/profil.png" class="profil-img">
                <h1 class="player-name">${array[i].firstname} ${array[i].lastname}</h1>
                <img src="img/time.png" class="time-img">
                <h1 class="time">${array[i].jail_time} secondes</h1>
                <img src="img/percentage.png" class="percentage-img">
                <h1 class="percentage">${Math.round((array[i].jail_time - array[i].jail_ref) / (0 - array[i].jail_ref) * 100)}%</h1>
                <button class="unjail-btn" onclick="unJail('${array[i].identifier}')">UNJAIL</button>
                <button class="raison-btn" onclick="raison('${array[i].jail_reason}', '${array[i].identifier}')">RAISON</button>
            </div>
            `
        }
 }

 function raison(reason, id) {
    $('.jail-reason').remove();
    $('#jail-reason').fadeIn(500);
    $('#close-reason').fadeIn(500);
    var elem = document.getElementById("jail-reason");
    elem.innerHTML += `
            <div class="jail-reason">
                <input type="text" placeholder="Raison du jail" id="input-reason2">
                <button class="validtxt-btn" onclick="valideReason('${id}')">VALIDER LES MODIFICATIONS</button>
            </div>
            `
            document.getElementById('input-reason2').value = reason;
}

function unJail(id) {
    $.post('https://nJail/Unjail', JSON.stringify({
        id: id,
    }))
    $.post('https://nJail/close', JSON.stringify({}))
    $('#jail-pannel').fadeOut(500);
    setTimeout(function(){
        $('.player-list').remove();
    }, 500);
}

function valideReason(id) {
    let inputReason = $("#input-reason2").val();
    document.getElementById('input-reason2').value = inputReason;
    $.post('https://nJail/ChangeReason', JSON.stringify({
        id: id,
        reason: inputReason
    }))
}


function JailPlayer() {
    let inputId = $("#input-id").val();
    let inputTime = $("#input-time").val();
    let inputReason = $("#input-reason").val();

    if (inputId.length >= 1) {
        $.post('https://nJail/JailPlayer', JSON.stringify({
            box: box,
            id: inputId
        }));
        close()
    }
}

$("#jail-player").click(function() {
    let inputId = $("#input-id").val();
    let inputTime = $("#input-time").val();
    let inputReason = $("#input-reason").val();

    if (inputId.length >= 1) {
        $('.id-state').css("background-color", "#12e70b")
        $('.id-state').css("box-shadow", "#12e70b 0px 0px 6px")
        if (inputTime.length >= 1) {
            $('.time-state').css("background-color", "#12e70b")
            $('.time-state').css("box-shadow", "#12e70b 0px 0px 6px")
            if (inputReason.length >= 1) {
                $('.reason-state').css("background-color", "#12e70b")
                $('.reason-state').css("box-shadow", "#12e70b 0px 0px 6px")
                $.post('https://nJail/JailPlayer', JSON.stringify({
                    id: inputId,
                    time: inputTime,
                    reason: inputReason
                }));
            } else {
                $('.reason-state').css("background-color", "#ff0000")
                $('.reason-state').css("box-shadow", "#ff0000 0px 0px 6px")
            };
        } else {
            $('.time-state').css("background-color", "#ff0000")
            $('.time-state').css("box-shadow", "#ff0000 0px 0px 6px")
        };
    } else {
        $('.id-state').css("background-color", "#ff0000")
        $('.id-state').css("box-shadow", "#ff0000 0px 0px 6px")
    };
    return
})


$("#close-jail").click(function() {
    $.post('https://nJail/close', JSON.stringify({}))
    $('body').fadeOut();
    $('#jail-reason').fadeOut(500);
})

$("#close-reason").click(function() {

    $('#jail-reason').fadeOut(500);
    $('#close-reason').fadeOut(500);
    setTimeout(function(){
        $('.jail-reason').remove();
    }, 500);
})

$("#close-pannel").click(function() {
    $.post('https://nJail/close', JSON.stringify({}))
    $('#jail-pannel').fadeOut(500);
    setTimeout(function(){
        $('.player-list').remove();
    }, 500);
})


$("#two-min").click(function() {
    document.getElementById('input-time').value = '120';
})

$("#five-min").click(function() {
    document.getElementById('input-time').value = '300';
})

$("#trente-min").click(function() {
    document.getElementById('input-time').value = '1800';
})

$("#un-min").click(function() {
    document.getElementById('input-time').value = '3600';
})