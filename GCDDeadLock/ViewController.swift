//
//  ViewController.swift
//  GCDDeadLock
//
//  Created by Lix on 16/11/1.
//  Copyright (c) 2016 Lix. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
    super.viewDidLoad()
//      gcdLockDemo1()
//        gcdLockDemo2()
//        gcdLockDemo3()
//        gcdLockDemo4()
        gcdLockDemo5()
        
    }

    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()

    }

    /*
     * GCD死锁
     *
     * dispatch_sync表示是一个同步线程；
     *
     * dispatch_get_main_queue表示运行在主线程中的主队列；
     *
     * 任务2是同步线程的任务。
     */

    //任务3要等任务2执行完才能执行，任务2由排在任务3后面，意味着任务2要在任务3执行完才能执行，所以他们进入了互相等待的局面。【既然这样，那干脆就卡在这里吧】这就是死锁。
    func gcdLockDemo1() {
       print("1")   //任务1
        
        DispatchQueue.main.sync {
            print("2")  //任务2
        }
        
        print("3")  //任务3
    }
   
    /*
     *  首先执行任务1，接下来会遇到一个同步线程，程序会进入等待。等待任务2执行完成以后，才能继续执行任务3。从dispatch_get_global_queue可以看出，任务2被加入到了全局的并行队列中，当并行队列执行完任务2以后，返回到主队列，继续执行任务3。
     *
     */
    func gcdLockDemo2() {
        print("1")
        
        DispatchQueue.global(qos: .default).sync {
            print("2")
        }
        
        print("3")
    }
    
    /*
     * 执行任务1；
     
     * 遇到异步线程，将【任务2、同步线程、任务4】加入串行队列中。因为是异步线程，所以在主线程中的任务5不必等待异步线程中的所有任务完成；
     
     * 因为任务5不必等待，所以2和5的输出顺序不能确定；
     
     * 任务2执行完以后，遇到同步线程，这时，将任务3加入串行队列；
     
     * 又因为任务4比任务3早加入串行队列，所以，任务3要等待任务4完成以后，才能执行。但是任务3所在的同步线程会阻塞，所以任务4必须等任务3执行完以后再执行。这就又陷入了无限的等待中，造成死锁。
     *
     *
     *
     */
    func gcdLockDemo3() {
        let queue = DispatchQueue(label: "serealQueue", qos: .default)
        print("1")
        queue.async {
            print("2")
            queue.sync {
                print("3")
            }
            print("4")
        }
        print("5")
    }
    /**
      *  首先，将【任务1、异步线程、任务5】加入Main Queue中，异步线程中的任务是：【任务2、同步线程、任务4】。
         
         所以，先执行任务1，然后将异步线程中的任务加入到Global Queue中，因为异步线程，所以任务5不用等待，结果就是2和5的输出顺序不一定。
         
         然后再看异步线程中的任务执行顺序。任务2执行完以后，遇到同步线程。将同步线程中的任务加入到Main Queue中，这时加入的任务3在任务5的后面。
         
         当任务3执行完以后，没有了阻塞，程序继续执行任务4。
         
         从以上的分析来看，得到的几个结果：1最先执行；2和5顺序不一定；4一定在3后面。
     *
     */
    func gcdLockDemo4() {
        print("1")
        DispatchQueue.global(qos: .default).async {
            print("2")
            DispatchQueue.main.sync {
                print("3")
            }
            print("4")
        }
        print("5")
    }
    
    /**
     *
     * 和上面几个案例的分析类似，先来看看都有哪些任务加入了Main Queue：【异步线程、任务4、死循环、任务5】。
     
       在加入到Global Queue异步线程中的任务有：【任务1、同步线程、任务3】。
     
       第一个就是异步线程，任务4不用等待，所以结果任务1和任务4顺序不一定。
     
       任务4完成后，程序进入死循环，Main Queue阻塞。但是加入到Global Queue的异步线程不受影响，继续执行任务1后面的同步线程。
     
       同步线程中，将任务2加入到了主线程，并且，任务3等待任务2完成以后才能执行。这时的主线程，已经被死循环阻塞了。所以任务2无法执行，当然任务3也无法执行，在死循环后的任务5也不会执行。
     
       最终，只能得到1和4顺序不定的结果。
     */
    
    func gcdLockDemo5() {
        DispatchQueue.global(qos: .default).async {
            print("1")
            DispatchQueue.main.sync {
                print("2")
            }
            print("3")
        }
        print("4")
        while (1 > 0) {
            
        }
        print("5")
    }
}
