import { LightningElement, api } from 'lwc';
import FORM_FACTOR from "@salesforce/client/formFactor";

export default class Modal extends LightningElement {
    _rendered = false;
    _size;
    _showHeader = true;
    _title;
    _showSubTitle = false;
    _showFooter = true;
    _showClose = true;
    _headerClass = '';
    _bodyClass = '';
    _footerClass = '';

    isIos = /iphone|ipad|ipod/i.test(window.navigator.userAgent);

    @api closeIconSize = "small";

    @api set title(value) {
        this._title = value;
    }

    get title() {
        return this._title;
    }

    @api set showHeader(value) {
        this._showHeader = value;
    }

    get showHeader() {
        return this._showHeader;
    }

    @api set showSubTitle(value) {
        this._showSubTitle = value;
    }

    get showSubTitle() {
        return this._showSubTitle;
    }

    @api set showFooter(value) {
        this._showFooter = value;
    }

    get showFooter() {
        return this._showFooter;
    }

    @api set showClose(value) {
        this._showClose = value;
    }

    get showClose() {
        return this.isDesktop && this._showClose;
    }

    @api set size(value) {
        this._size = value;
    }

    get size() {
        return 'slds-modal slds-fade-in-open ' + (this.isDesktop ? `slds-modal_${ this._size } desktop-modal` : 'mobile-modal');
    }

    @api set headerClass(value) {
        this._headerClass = value;
    }

    get headerClass() {
        return 'slds-modal__header ' + this._headerClass;
    }

    @api set bodyClass(value) {
        this._bodyClass = value;
    }

    get bodyClass() {
        return 'slds-modal__content slds-p-around_small ' + this._bodyClass;
    }

    @api set footerClass(value) {
        this._footerClass = value;
    }
    
    get footerClass() {
        return 'slds-modal__footer ' + this._footerClass + (this.isDesktop ? '' : ' slds-text-align_center');
    }

    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

    renderedCallback() {
        if (!this.isDesktop && !this._rendered) {
            this._rendered = true;
            this.mobileOnScroll();
            window.addEventListener('scroll', this.mobileOnScroll, true);
        }
    }

    disconnectedCallback() {
        if (!this.isDesktop) {
            window.removeEventListener('scroll', this.mobileOnScroll, true);
        }
    }

    mobileOnScroll = () => {
        const offset = `${ this.isIos ? window.scrollY - 51 : window.scrollY }px`; //51px offset for IOS
        this.template.querySelector('section').style.top = offset;
        this.template.querySelector('.slds-backdrop').style.top = offset;
    }

    onClose() {
        const closeEvent = new CustomEvent('close', {
            detail: null,
        });
        this.dispatchEvent(closeEvent);
    }

}