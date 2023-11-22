import { loadStyle } from "lightning/platformResourceLoader";
import CommonStyles from "@salesforce/resourceUrl/CommonStyles";

const importCommonStyles = (that) =>
    new Promise(async (resolve) => {
    const [error] = await to(loadStyle(that, CommonStyles));
    if (error) {
        return resolve(error);
    } else {
        resolve();
    }
});

const to = (promise) =>
  promise
    .then((data) => {
      return [null, data];
    })
    .catch((err) => [err]);

export {importCommonStyles};