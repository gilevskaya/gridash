%raw("require('./tailwind.css')")

type tItem = {
  mutable x: option<int>,
  mutable y: option<int>,
  mutable w: option<int>,
  mutable h: option<int>,
}
type tFixed =
  | Row(int, string)
  | Column(int, string)
// type tFixed = {
//   mutable row: int,
//   mutable size: string,
// } | {
//     mutable column: int,
//   mutable size: string,
// }

open Js.Array2

module AddButton = {
  @react.component
  let make = (~name, ~onClick) => {
    <button className="mt-2 font-semibold text-gray-400" onClick>
      {"+ "->React.string} <span className="hover:underline"> {name->React.string} </span>
    </button>
  }
}

/////////
module DashboardMock = {
  module Item = {
    @react.component
    let make = (~name) => {
      <div className="h-full bg-gray-300 border border-gray-400 flex items-center justify-center">
        <div className="text-xl font-semibold text-gray-400"> {name->React.string} </div>
      </div>
    }
  }

  @react.component
  let make = (~rows, ~columns, ~gap, ~items) => {
    <Index rows columns gap> {items->mapi((item, ind) => {
        let indStr = (ind + 1)->Js.Int.toString
        let {x, y, w, h} = item
        <Index.Item key={indStr} x y w h> <Item name={indStr} /> </Index.Item>
      })->React.array} </Index>
  }
}

/////////
module DahsboardMainSettings = {
  module Input = {
    type t =
      | Num(int)
      | Str(string)

    @react.component
    let make = (~name, ~value: t, ~onChange) => {
      let (valueStr, inputType) = switch value {
      | Num(n) => (n->Js.Int.toString, "number")
      | Str(s) => (s, "text")
      }
      <div className="flex justify-between items-center py-2">
        <label className="text-sm text-gray-800 mr-2"> {name->React.string} </label>
        <input
          type_={inputType}
          className="h-7 border border-gray-300"
          value={valueStr}
          onChange={e => ReactEvent.Form.target(e)["value"]->onChange}
        />
      </div>
    }
  }

  @react.component
  let make = (~rows, ~setRows, ~columns, ~setColumns, ~gap, ~setGap) => {
    <div className="mb-1">
      <div className="text-lg pb-4 font-medium"> {"Settings"->React.string} </div>
      <Input name="rows" value={Input.Num(rows)} onChange={setRows} />
      <Input name="columns" value={Input.Num(columns)} onChange={setColumns} />
      <Input name="gap" value={Input.Str(gap)} onChange={setGap} />
    </div>
  }
}

/////////
module DashboardFixedSettings = {
  module Input = {
    @react.component
    let make = (~kind, ~num, ~size) => {
      <div className="my-3 h-7 border border-gray-300 flex">
        <select className="border-none pt-0 mr-0.5">
          <option value="row"> {"row"->React.string} </option>
          <option value="column"> {"column"->React.string} </option>
        </select>
        <input className="w-1/3 border-none mr-0.5" type_="number" value={num->Js.Int.toString} />
        <input className="w-1/3 border-none" type_="text" value={size} />
      </div>
    }
  }

  @react.component
  let make = (~fixed, ~setFixed) => {
    <div>
      <AddButton name="add fixed row / column" onClick={_ => "wow"->Js.log} />
      {fixed->mapi((item, ind) => {
        let (kind, num, size) = switch item {
        | Row(n, s) => ("row", n, s)
        | Column(n, s) => ("column", n, s)
        }
        <Input key={ind->Js.Int.toString} kind num size />
      })->React.array}
    </div>
  }
}

/////////
module ItemsSettings = {
  module Value = {
    @react.component
    let make = (~name, ~value, ~setValue) => {
      let valueStr = switch value {
      | Some(n) => n->Js.Int.toString
      | None => ""
      }
      <div className="flex flex-col flex-1 border-t border-b border-r border-gray-300 w-1/4">
        <label className="text-center bg-gray-200 text-gray-600 text-sm">
          {name->React.string}
        </label>
        <input
          type_="number"
          className="w-full border-none h-6"
          value={valueStr}
          onChange={e => {
            let v = ReactEvent.Form.target(e)["value"]
            if v === "" {
              setValue(None)
            } else {
              setValue(Some(v->Js.Float.fromString->Belt.Float.toInt))
            }
          }}
        />
      </div>
    }
  }

  module Input = {
    @react.component
    let make = (~id: int, ~item, ~setItem) => {
      <div className="my-4 flex bg-gray-300 border border-gray-400 ">
        <div className="pl-1 w-8 border-r border-gray-300 text-lg font-semibold text-gray-400">
          {id->Js.Int.toString->React.string}
        </div>
        <Value name="x" value={item.x} setValue={v => setItem({...item, x: v})} />
        <Value name="y" value={item.y} setValue={v => setItem({...item, y: v})} />
        <Value name="w" value={item.w} setValue={v => setItem({...item, w: v})} />
        <Value name="h" value={item.h} setValue={v => setItem({...item, h: v})} />
      </div>
    }
  }

  @react.component
  let make = (~items, ~setItems) => {
    <div> <AddButton name="add item" onClick={_ => setItems(prevItems => {
            let _ = prevItems->push({x: None, y: None, w: None, h: None})
            prevItems->copy
          })} /> <div> {items->mapi((item, ind) => {
          <Input
            key={ind->Js.Int.toString}
            id={ind + 1}
            item
            setItem={i => {
              setItems(items => {
                let _ = Belt.Array.set(items, ind, i)
                items->copy
              })
            }}
          />
        })->React.array} </div> </div>
  }
}

/////////
module App = {
  @react.component
  let make = () => {
    let (rows, setRows) = React.useState(_ => 6)
    let (columns, setColumns) = React.useState(_ => 3)
    let (gap, setGap) = React.useState(_ => "0.5rem")
    let (items, setItems) = React.useState(_ => [
      {x: None, y: Some(1), w: None, h: Some(2)},
      {x: None, y: None, w: None, h: None},
    ])
    let (fixed, setFixed) = React.useState(_ => [Row(0, "150px")])

    <div className="h-screen p-10 bg-gray-100 flex flex-col">
      <div className="text-3xl mb-8"> {"ReScript CSS Grid Dashboard"->React.string} </div>
      <div className="flex-1 flex w-full">
        <div className="w-full shadow-md bg-gray-200">
          <DashboardMock rows columns gap items />
        </div>
        <div className="ml-8 w-96 flex flex-col">
          <DahsboardMainSettings rows setRows columns setColumns gap setGap />
          <DashboardFixedSettings fixed setFixed />
          <ItemsSettings items setItems />
        </div>
      </div>
    </div>
  }
}

ReactDOMRe.renderToElementWithId(<App />, "root")