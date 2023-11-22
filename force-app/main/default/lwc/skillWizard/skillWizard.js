import { LightningElement } from 'lwc';

const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
    {
        type: 'text',
        fieldName: 'name',
        label: 'Skill Group',
        initialWidth: 300,
    },
    {
        type: 'text',
        fieldName: 'market',
        label: 'Market',
    },
    {
        type: 'text',
        fieldName: 'function',
        label: 'Function',
    },
    {
        type: 'text',
        fieldName: 'plural_name',
        label: 'Plural'
    }
];

export default class SkillWizard extends LightningElement {
    gridLoadingState = false;
    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
}