package main

import (
	"bytes"
	"fmt"
	"log"
	"net"
	"net/smtp"
)

func main() {
	mxrecords, _ := net.LookupMX("scandiborn.com")
	for _, mx := range mxrecords {
		fmt.Println(mx.Host, mx.Pref)
	}
	c, err := smtp.Dial(fmt.Sprintf("%s:%d", mxrecords[0].Host, mxrecords[0].Pref))
	if err != nil {
		log.Fatal(err)
	}
	defer c.Close()
	// Set the sender and recipient.
	c.Mail("sender@example.org")
	c.Rcpt("mladen@scandiborn.comt")
	// Send the email body.
	wc, err := c.Data()
	if err != nil {
		log.Fatal(err)
	}
	defer wc.Close()
	buf := bytes.NewBufferString("This is the email body.")
	if _, err = buf.WriteTo(wc); err != nil {
		log.Fatal(err)
	}
}
