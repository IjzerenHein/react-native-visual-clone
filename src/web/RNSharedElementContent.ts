import { Rect } from "./Rect";

export class RNSharedElementContent {
  public readonly size: Rect;

  constructor(size: Rect) {
    this.size = size;
  }

  static getSize(element: any): Rect | null {

    //console.log('RNSharedElementContent.getSize: ', element);

    return new Rect({
      x: 0,
      y: 0,
      width: element.clientWidth || 0,
      height: element.clientHeight || 0,
    })
  }
}