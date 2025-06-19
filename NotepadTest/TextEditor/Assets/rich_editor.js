// Copyright (c) 2025 Hoang Thanh Duong
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//

"use strict";

var RE = {};

window.onload = function () {
    RE.editor = document.getElementById("editor");
    RE.callback("ready");
    RE.bindEvents();
};

RE.callbackQueue = [];
RE.callback = function (method) {
    RE.callbackQueue.push(method);
    setTimeout(() => window.location.href = "re-callback://", 0);
};

RE.getCommandQueue = function () {
    const commands = JSON.stringify(RE.callbackQueue);
    RE.callbackQueue = [];
    return commands;
};

RE.bindEvents = function () {
    document.addEventListener("selectionchange", RE.backuprange);
    RE.editor.addEventListener("input", () => {
        RE.updatePlaceholder();
        RE.backuprange();
        RE.callback("input");
    });
    RE.editor.addEventListener("focus", () => {
        RE.backuprange();
        RE.callback("focus");
    });
    RE.editor.addEventListener("blur", () => RE.callback("blur"));
};

RE.setHtml = function (html) {
    const wrapper = document.createElement("div");
    wrapper.innerHTML = html;
    wrapper.querySelectorAll("img").forEach(img => img.onload = RE.updateHeight);
    RE.editor.innerHTML = wrapper.innerHTML;
    RE.updatePlaceholder();
};

RE.getHtml = () => RE.editor.innerHTML;
RE.getText = () => RE.editor.innerText;
RE.setPlaceholderText = text => RE.editor.setAttribute("placeholder", text);

RE.updatePlaceholder = function () {
    if (RE.editor.innerHTML.includes("img") || RE.editor.textContent.trim().length > 0) {
        RE.editor.classList.remove("placeholder");
    } else {
        RE.editor.classList.add("placeholder");
    }
};

RE.prepareInsert = () => RE.backuprange();

RE.backuprange = function () {
    const sel = window.getSelection();
    if (sel.rangeCount > 0) {
        const range = sel.getRangeAt(0);
        RE.currentSelection = {
            startContainer: range.startContainer,
            startOffset: range.startOffset,
            endContainer: range.endContainer,
            endOffset: range.endOffset
        };
    }
};

RE.restorerange = function () {
    const sel = window.getSelection();
    sel.removeAllRanges();
    if (!RE.currentSelection) return;
    try {
        const range = document.createRange();
        range.setStart(RE.currentSelection.startContainer, RE.currentSelection.startOffset);
        range.setEnd(RE.currentSelection.endContainer, RE.currentSelection.endOffset);
        sel.addRange(range);
    } catch (e) {
        console.warn("Cannot restore range:", e);
    }
};

RE.insertHTML = function (html) {
    RE.restorerange();
    document.execCommand("insertHTML", false, html);
};

RE.insertCheckbox = function () {
    RE.prepareInsert();
    RE.insertHTML("<input type='checkbox'>");
};

RE.insertImage = function (url, alt = "image") {
    const img = document.createElement("img");
    img.src = url;
    img.alt = alt;
    img.onload = RE.updateHeight;
    RE.insertHTML(img.outerHTML);
    RE.callback("input");
};

RE.insertLink = function (url, title) {
    RE.restorerange();
    const sel = window.getSelection();
    if (sel.toString().length > 0 && sel.rangeCount > 0) {
        const a = document.createElement("a");
        a.href = url;
        a.title = title;
        const range = sel.getRangeAt(0);
        range.surroundContents(a);
        sel.removeAllRanges();
        sel.addRange(range);
    }
    RE.callback("input");
};

RE.focus = () => RE.editor.focus();
RE.blurFocus = () => RE.editor.blur();

// Text styling
RE.setBold = () => document.execCommand("bold");
RE.setItalic = () => document.execCommand("italic");
RE.setUnderline = () => document.execCommand("underline");
RE.setStrikeThrough = () => document.execCommand("strikeThrough");
RE.setSubscript = () => document.execCommand("subscript");
RE.setSuperscript = () => document.execCommand("superscript");
RE.setHeading = level => document.execCommand("formatBlock", false, `<h${level}>`);
RE.removeFormat = () => document.execCommand("removeFormat");

// Lists & blocks
RE.setOrderedList = () => document.execCommand("insertOrderedList");
RE.setUnorderedList = () => document.execCommand("insertUnorderedList");
RE.setBlockquote = () => document.execCommand("formatBlock", false, "<blockquote>");
RE.setIndent = () => document.execCommand("indent");
RE.setOutdent = () => document.execCommand("outdent");

// Alignment
RE.setJustifyLeft = () => document.execCommand("justifyLeft");
RE.setJustifyCenter = () => document.execCommand("justifyCenter");
RE.setJustifyRight = () => document.execCommand("justifyRight");

// Colors
RE.setTextColor = color => {
    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand("foreColor", false, color);
    document.execCommand("styleWithCSS", null, false);
};

RE.setTextBackgroundColor = color => {
    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand("hiliteColor", false, color);
    document.execCommand("styleWithCSS", null, false);
};

RE.updateHeight = function () {
    RE.callback("updateHeight");
};
