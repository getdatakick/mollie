{**
* Copyright (c) 2012-2018, mollie-ui b.V.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice,
*    this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
* DAMAGE.
*
* @author     Mollie B.V. <info@mollie.nl>
* @copyright  Mollie B.V.
* @license    Berkeley Software Distribution License (BSD-License 2) http://www.opensource.org/licenses/bsd-license.php
* @category   Mollie
* @package    Mollie
* @link       https://www.mollie.nl
*}
{extends file="helpers/form/form.tpl"}

{block name="input"}
  {if $input.type === 'mollie-br'}
    <br>
  {elseif $input.type === 'mollie-warning'}
    <div class="alert alert-warning">{$input.message|escape:'htmlall':'UTF-8'}</div>
  {elseif $input.type === 'mollie-methods'}
    <section class="module_list" style="max-width: 440px">
      <ul class="list-unstyled sortable">
        {foreach $input.methods as $index => $method}
          <li class="module_list_item draggable"
              draggable="true"
              data-pos="{$index|intval}"
              data-method="{$method['id']|escape:'htmlall':'UTF-8'}"
          >
            <div class="module_col_position dragHandle">
              <span class="positions">{$index + 1|intval}</span>
              <div class="btn-group-vertical">
                <button class="mollie-ui btn btn-primary btn-xs mollie-up">
                  <i class="icon-chevron-up"></i>
                </button>
                <button class="mollie-ui btn btn-primary btn-xs mollie-down">
                  <i class="icon-chevron-down"></i>
                </button>
              </div>
            </div>
            <div class="module_col_icon">
              <img width="57" src="{$method['image']|escape:'htmlall':'UTF-8'}" alt="mollie">
            </div>
            <div class="module_col_infos">
              <div style="display: inline-block; margin-top: 5px">
                <span class="module_name">
                  {$method['name']|escape:'htmlall':'UTF-8'}
                </span>
              </div>
              {if version_compare($smarty.const._PS_VERSION_, '1.6.0.0', '>=')}
                {if empty($method['available'])}
                  <span style="float:right;width:100px;right:20px;top:10px;position:relative;"
                        title="{l s='This payment method is not available on the Payments API. Switch to the Orders API in order to activate this method.' mod='mollie'}"
                  >
                    <i class="icon icon-exclamation-triangle"></i> {l s='Not available' mod='mollie'}
                  </span>
                {else}
                  <span class="switch prestashop-switch"
                        style="float:right;position:relative;width:100px;right:20px;top:0;"
                        title="{l s='This payment method is not available on the Payments API. Switch to the Orders API in order to activate this method.' mod='mollie'}"
                  >
                    <input type="radio"
                           data-mollie-check
                           name="MOLLIE_METHOD_ENABLED_{$method['id']|escape:'htmlall':'UTF-8'}"
                           id="MOLLIE_METHOD_ENABLED_on_{$method['id']|escape:'htmlall':'UTF-8'}"
                           value="1"
                           {if !empty($method['enabled'])}checked="checked"{/if}
                    >
                    <label for="MOLLIE_METHOD_ENABLED_on_{$method['id']|escape:'htmlall':'UTF-8'}">
                      {Translate::getAdminTranslation('Yes')|escape:'htmlall':'UTF-8'}
                    </label>
                    <input type="radio"
                           name="MOLLIE_METHOD_ENABLED_{$method['id']|escape:'htmlall':'UTF-8'}"
                           id="MOLLIE_METHOD_ENABLED_off_{$method['id']|escape:'htmlall':'UTF-8'}"
                           value=""
                           {if empty($method['enabled'])}checked="checked"{/if}
                    >
                    <label for="MOLLIE_METHOD_ENABLED_off_{$method['id']|escape:'htmlall':'UTF-8'}">
                      {Translate::getAdminTranslation('No')|escape:'htmlall':'UTF-8'}
                    </label>
                    <a class="slide-button btn"></a>
                  </span>
                {/if}
              {else}
                {if empty($method['available'])}
                  <span style="float:right;width:100px;right:20px;top:10px;position:relative;">
                    ⚠ {l s='Not available' mod='mollie'}
                  </span>
                {else}
                  <label class="mollie_switch" style="float:right;width:60px;height:24px;right:20px;top:5px;">
                    <input type="checkbox"
                           value="1"
                           style="width: auto;"
                           {if !empty($method['enabled'])}checked="checked"{/if}
                    >
                    <span class="mollie_slider"></span>
                  </label>
                {/if}
              {/if}
            </div>
          </li>
        {/foreach}
      </ul>
    </section>
    <input type="hidden" name="{$input.name|escape:'htmlall':'UTF-8'}" id="{$input.name|escape:'htmlall':'UTF-8'}">
    <script type="text/javascript">
      (function () {
        function setInput() {
          var config = [];
          var position = 0;
          var $sortableLis = $('.sortable > li');
          $sortableLis.each(function (index, elem) {
            var $elem = $(elem);
            $elem.find('button.mollie-up').attr('disabled', index === 0);
            $elem.find('button.mollie-down').attr('disabled', index === ($sortableLis.length - 1));
            config.push({
              id: $elem.attr('data-method'),
              position: position++,
              enabled: $elem.find('{if version_compare($smarty.const._PS_VERSION_, '1.6.0.0', '>=')}input[type=radio]{else}input[type=checkbox]{/if}')[0].checked,
            });
          });
          $('#{$input.name|escape:'javascript':'UTF-8'}').val(JSON.stringify(config));
        }

        function setPositions() {
          var $sortableLis = $('.sortable > li');
          $sortableLis.each(function (index, elem) {
            var $elem = $(elem);
            $elem.find('button.mollie-up').attr('disabled', index === 0);
            $elem.find('button.mollie-down').attr('disabled', index === ($sortableLis.length - 1));
            $elem.attr('data-pos', index++);
            $elem.find('.positions').text(index);
          });
        }

        function moveUp(event) {
          event.preventDefault();
          var $elem = $(event.target).closest('li');
          $elem.prev().insertAfter($elem);
          setPositions();
        }

        function moveDown(event) {
          event.preventDefault();
          var $elem = $(event.target).closest('li');
          console.log($elem);
          $elem.next().insertBefore($elem);
          setPositions();
        }

        function init () {
          if (typeof $ === 'undefined') {
            setTimeout(init, 100);
            return;
          }

          $('.sortable').sortable({
            forcePlaceholderSize: true
          }).on('sortupdate', function () {
            setPositions();
            setInput();
          });
          var $sortableLis = $('.sortable > li');
          $sortableLis.each(function (index, elem) {
            console.log(index);
            var $elem = $(elem);
            $elem.find('button.mollie-up').click(moveUp).attr('disabled', index === 0);
            $elem.find('button.mollie-down').click(moveDown).attr('disabled', index === ($sortableLis.length - 1));
            {if version_compare($smarty.const._PS_VERSION_, '1.6.0.0', '>=')}
              $elem.find('input[type=radio]').change(setInput);
            {else}
              $elem.find('input[type=checkbox]').change(setInput);
            {/if}
          });
          setInput();
        }
        init();
      }());
    </script>
  {elseif $input.type === 'mollie-h1'}
    <br>
    <h1>{$input.title|escape:'html':'UTF-8'}</h1>
  {elseif $input.type === 'mollie-h2'}
    <br>
    <h2>{$input.title|escape:'html':'UTF-8'}</h2>
  {elseif $input.type === 'mollie-h3'}
    <br>
    <h3>{$input.title|escape:'html':'UTF-8'}</h3>
  {elseif $input.type == 'switch' && version_compare($smarty.const._PS_VERSION_, '1.6.0.0', '<')}
    {foreach $input.values as $value}
      <input type="radio" name="{$input.name|escape:'htmlall':'UTF-8'}"
             id="{$input.name|escape:'htmlall':'UTF-8'}_{$value.id|escape:'htmlall':'UTF-8'}"
             value="{$value.value|escape:'htmlall':'UTF-8'}"
             {if $fields_value[$input.name] == $value.value}checked="checked"{/if}
              {if isset($input.disabled) && $input.disabled}disabled="disabled"{/if} />
      <label class="t" for="{$input.name|escape:'htmlall':'UTF-8'}_{$value.id|escape:'htmlall':'UTF-8'}">
        {if isset($input.is_bool) && $input.is_bool == true}
          {if $value.value == 1}
            <img src="../img/admin/enabled.gif" alt="{$value.label|escape:'htmlall':'UTF-8'}"
                 title="{$value.label|escape:'htmlall':'UTF-8'}" />
          {else}
            <img src="../img/admin/disabled.gif" alt="{$value.label|escape:'htmlall':'UTF-8'}"
                 title="{$value.label|escape:'htmlall':'UTF-8'}" />
          {/if}
        {else}
          {$value.label|escape:'htmlall':'UTF-8'}
        {/if}
      </label>
      {if isset($input.br) && $input.br}<br />{/if}
      {if isset($value.p) && $value.p}<p>{$value.p|escape:'htmlall':'UTF-8'}</p>{/if}
    {/foreach}
  {else}
    {$smarty.block.parent}
  {/if}
{/block}
