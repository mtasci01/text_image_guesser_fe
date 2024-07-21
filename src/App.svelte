<script>
  let textFiles = [];
  let image_guessing_main_visible = false;
  let text_guessing_main_visible = false;
  let text_guessing_word_mode_visible = false;
  let text_guessing_char_mode_visible = false;
  let text_prob = 0;
  let game_id = null;
  let text_text = '';
  let text_file = null;
  let charGuessList = [];
  let labeledImgFile = null;
  let numImgStored = 0;
  let imgGameId = null;
  let imgGameSrc = null;
  let imgGameLabel = null;
  let imgLabels = [];
  let labelGuess = null;
  

  let apiUrl = "";
  fetch("src/assets/config.json")
  .then((res) => res.json())
  .then((resp) => {
    apiUrl = resp.apiUrl;
    getSavedTextFiles();
    getSavedImgFilesNum(); 
    getAllImgLabels();
  });

  async function getSavedTextFiles() {
    const response = await fetch(apiUrl + '/text/get_saved_files');
    textFiles = await response.json();
  }

  async function getSavedImgFilesNum() {
    const response = await fetch(apiUrl + '/img/get_saved_img_num');
    numImgStored = await response.json();
  }

  async function startImgGame() {
    const response = await fetch(apiUrl + '/img/start_game');
    let json = await response.json();
    imgGameId = json['game_id'];
    imgGameLabel = json['label'];
    refreshImgGameSrc(false);

  }

  function refreshImgGameSrc(origin){
    let originStr ="";
    if (origin == true){
      originStr="_original"
    }
    imgGameSrc = apiUrl + '/img/download_cached' + originStr + '?game_id='+imgGameId + "&t=" + (new Date()).getTime()
  }

  async function clickImg(event){
    const img = event.target;
    const rect = img.getBoundingClientRect();
    let relativeX = event.clientX - rect.left;
    let relativeY = event.clientY - rect.top;  
    let imgSize = rect.width;
    const response = await fetch(apiUrl + '/img/click_img_sent?p_x=' + relativeX + '&p_y=' + relativeY + '&game_id='+ imgGameId + "&client_img_size=" + imgSize);
    let json = await response.json();
    refreshImgGameSrc(false);
  }
  

  function clickChar(event) {
    let ix = event.target.attributes['data-ix'].value;
    charGuessList[ix]['to_replace'] = false;
  }

  async function playTextBtnPress(event){
    
    let fileId = event.target.attributes['data-fileid'].value;
    let probStr = prompt("Enter probability of hiding element (between 0 and 1)");
    text_prob = parseFloat(probStr);
    
    if (isNaN(text_prob) || !(text_prob > 0 && text_prob < 1)){
      return;
    }
    
    const response = await fetch(apiUrl + '/text/start_game?docId=' + fileId + "&prob="+text_prob);
    let start_json = await response.json();
    game_id = start_json['game_id']
    text_text = start_json['text']
    text_guessing_word_mode_visible = true;
    text_guessing_char_mode_visible = false;

  }

  async function playCharTextBtnPress(event){
    
    let fileId = event.target.attributes['data-fileid'].value;
    let probStr = prompt("Enter probability of hiding element (between 0 and 1)");
    text_prob = parseFloat(probStr);
    
    if (isNaN(text_prob) || !(text_prob > 0 && text_prob < 1)){
      return;
    }
    
    const response = await fetch(apiUrl + '/text/start_char_game?file_id=' + fileId + "&prob="+text_prob);
    charGuessList = await response.json();
    text_guessing_word_mode_visible = false;
    text_guessing_char_mode_visible = true;

  }

  async function deleteTextBtnPress(event){
    
    let file_id = event.target.attributes['data-fileid'].value;
    let to_delete = confirm("Are you sure you want ot delete this file?");
    console.log(to_delete);
    if (to_delete){
      const response = await fetch(apiUrl + '/text/delete_file?file_id=' + file_id,{
              method: 'DELETE'
      });
      getSavedTextFiles();
    }
  }

  async function upload_text_file(event){
    console.log("here");
    const formData = new FormData();
    formData.append('file', text_file);
    console.log(text_file);
    
    const response = await fetch(apiUrl + '/text/upload_file',{method: 'POST',
        body: formData,
      
    });
    getSavedTextFiles();
  }

  async function uploadLabeledImg(event){
    const formData = new FormData();
    formData.append('file', labeledImgFile);
    let label = prompt("Enter the label");
    formData.append('label', label);
    
    const response = await fetch(apiUrl + '/img/upload_labeled_file?label='+label,{method: 'POST',
        body: formData,
      
    });
    getSavedImgFilesNum();
    getAllImgLabels();
  }

  let wordguess = "";

  async function wordGuessedKeydown(e) {
     if (e.key != 'Enter'){
      return;
     }

     const response = await fetch(apiUrl + '/text/guess_word?game_id=' + game_id + "&word="+wordguess);
     let json = await response.json();
     text_text = json['text']
     wordguess = '';

	}

  let revealnumber = "";

  async function revealNumberKeydown(e) {
     if (e.key != 'Enter'){
      return;
     }

     const response = await fetch(apiUrl + '/text/reveal_number?game_id=' + game_id + "&number="+revealnumber);
     let json = await response.json();
     text_text = json['text']
     revealnumber = '';

	}

  async function getAllImgLabels() {
     
     const response = await fetch(apiUrl + '/img/get_all_labels');
     let json = await response.json();
     imgLabels = json

	}


  function revealLabel() {
    alert(imgGameLabel);
  }

  function handleFileChange(event) {
    text_file = event.target.files[0];
  }

  function handleImgsFile(event) {
    labeledImgFile = event.target.files[0];
  }

  function pressTextGuessingBtn(event) {
    image_guessing_main_visible = false;
    text_guessing_main_visible = true;
  }

  function pressImgtGuessingBtn(event) {
    image_guessing_main_visible = true;
    text_guessing_main_visible = false;
  }

  async function labelGuessedKeydown(e) {
     if (e.key != 'Enter'){
      return;
     }

     if (labelGuess == imgGameLabel){
      alert("CORRECT!")
     }

     refreshImgGameSrc(true);
	}

</script>
<div style='font-family:Times New Roman;'>
  <button on:click={(event) => pressTextGuessingBtn(event)}>Text Guessing Game</button>
  <button on:click={(event) => pressImgtGuessingBtn(event)}>Image Guessing Game</button>
</div>
{#if image_guessing_main_visible}
  <div>
    <h1 style='font-family: Courier New;'>Image Guessing game!!</h1>
  </div>
  <div style='margin:10px'>
    <div style='font-weight:bold'>Upload your image file!</div>
    <div><input on:change={handleImgsFile} type="file"/>
    <button on:click={(event) => uploadLabeledImg(event)}>Upload</button></div>
  </div>
  <div>
  Num of files stored: {numImgStored}
  </div>
  {#if imgGameSrc}
  <div style='margin-bottom:10px'>
        <input type="text" bind:value={labelGuess} on:keydown={labelGuessedKeydown} list="imgLabelsL" placeholder="Guess the label" />
        <button on:click={revealLabel}>Reveal Label</button>

            <datalist id="imgLabelsL">
              {#each imgLabels as label}
                <option value="{label}">{label}</option>
              {/each}
                
            </datalist>
          </div>          
  <div>
    <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <img  on:click={(event) => clickImg(event)} style='max-width: 500px; max-height: 500px;' alt='guess img' src={imgGameSrc}/>
  </div>
  {/if}
  <button style='margin-top:10px' on:click={startImgGame}>Start game!</button>
{/if}
{#if text_guessing_main_visible}
  <div>
    <h1 style='font-family: Courier New;'>Text Guessing game!!</h1>
  </div>
  <div id='text_guessing_main'>
    <div id='text_guessing_file_list'>
      <div style='margin:10px'>
        <div style='font-weight:bold'>Upload your text file!</div>
        <div><input on:change={handleFileChange} type="file"/>
        <button on:click={(event) => upload_text_file(event)}>Upload</button></div>
      </div>
      <div>
        <table>
        {#each textFiles as textF}
          <tr style='font-family:Arial, Helvetica, sans-serif' id='textF_{textF.fileid}'>
            <td>{textF.filename}</td>
            <td><button data-fileid='{textF.fileid}' on:click={(event) => playTextBtnPress(event)}>Play word guessing mode</button></td>
            <td><button data-fileid='{textF.fileid}' on:click={(event) => playCharTextBtnPress(event)}>Play character guessing mode</button></td>
            <td><button data-fileid='{textF.fileid}' on:click={(event) => deleteTextBtnPress(event)}>Delete!</button></td>
          </tr>
      {/each}
      </table></div>
    </div>
    {#if text_guessing_word_mode_visible}
      <div id='text_guessing_word_mode'>
        <div>
          <div>Guess a word</div>
          <input type="text" bind:value={wordguess} on:keydown={wordGuessedKeydown} id='text_guessing_wordin'/>
        </div>
        <div>
          <div>Reveal Number</div>
          <input type="text" bind:value={revealnumber} on:keydown={revealNumberKeydown} id='text_guessing_revnumber'/>
        </div>
        <div style='padding-left:5px; border-left:1px solid black' id='text_guessing_textarea'>
            {text_text}
        </div>
      </div>
    {/if}
    {#if text_guessing_char_mode_visible}
    <div id='text_guessing_char_mode'>
      
      <!-- svelte-ignore a11y-no-static-element-interactions -->
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <div style='padding-left:5px; border-left:1px solid black' id='text_guessing_char_textarea'>
        {#each charGuessList as charGuess}
         {#if charGuess['to_replace']}
           <span data-ix='{charGuess['ix']}' on:click={(event) => clickChar(event)} class='ch_to_reveal'>?</span>
        {:else}
           {charGuess['char']}
         {/if}
        {/each}
      </div>
    </div>
  {/if}
  </div>
{/if}

<style>
  #text_guessing_main{
    display: flex;
  } 
  #text_guessing_file_list {
    flex: 50%;
  }
  #text_guessing_word_mode {
    flex: 50%;
  }
  #text_guessing_char_mode {
    flex: 50%;
  }
  :global(.ch_to_reveal) {
    color:red;
  }
  :global(.ch_to_reveal:hover) {
    cursor: pointer;
  }
</style>
