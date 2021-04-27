import path from 'path'
import { create, remove } from '../src/file'

const temp = path.join(__dirname, 'dist')

describe("file", () => {
  describe("create", () => {
    test('can create files', async () => {
      await create(path.join(temp, 'hello.txt'), 'Hello!')
      await create(path.join(temp, 'apple', 'banana', 'cherry.txt'), 'abc')
    })
    test('can remove files', async () => {
      await remove(path.join(temp, 'hello.txt'))
    })
    test('can remove folders', async () => {
      await remove(temp)
    })
  })
})